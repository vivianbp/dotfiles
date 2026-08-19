#!/usr/bin/env bash
# deploy.sh — bootstrap a new machine then apply the real NixOS config from dotfiles.
#
# Usage: ./deploy.sh [--skip-nixos-anywhere] <target-ip> <hostname>
#   --skip-nixos-anywhere  Skip the nixos-anywhere partitioning/install step and
#                          go straight to dotfiles setup. Use after a failed first run.
#   target-ip              IP of the target (must be booted from the installer ISO)
#   hostname               The new machine's hostname (e.g. terra, luna)
#
# Prerequisites:
#   - secrets/secrets.yaml exists and is sops-encrypted
#   - ~/.config/sops/age/keys.txt contains your age private key
#   - nixos-anywhere is on PATH (nix shell github:nix-community/nixos-anywhere)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_REPO="https://github.com/violetbp/dotfiles.git"
DOTFILES_USER="vboysepe"
AGE_KEY_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt"

# ── Phase 0: parse args ────────────────────────────────────────────────────────

SKIP_NIXOS_ANYWHERE=0
if [[ "${1:-}" == "--skip-nixos-anywhere" ]]; then
  SKIP_NIXOS_ANYWHERE=1
  shift
fi

TARGET_IP="${1:-}"
HOSTNAME="${2:-}"

[[ -z "$TARGET_IP" ]] && read -rp "Target IP: " TARGET_IP
[[ -z "$HOSTNAME"  ]] && read -rp "Hostname: " HOSTNAME

# ── Phase 1: validate prerequisites ───────────────────────────────────────────

if [[ ! -f "$AGE_KEY_FILE" ]]; then
  echo "ERROR: age key not found at $AGE_KEY_FILE"
  echo "  Run: age-keygen -o $AGE_KEY_FILE"
  exit 1
fi

if [[ ! -f "$SCRIPT_DIR/secrets/secrets.yaml" ]]; then
  echo "ERROR: secrets/secrets.yaml not found."
  echo "  Run: cp secrets/secrets.yaml.example secrets/secrets.yaml && sops -e -i secrets/secrets.yaml"
  exit 1
fi

# ── Phase 2: nixos-anywhere bootstrap ─────────────────────────────────────────

# Ensure a per-hostname stub exists in hostnameconfig/ so the local bootstrap
# flake (flake.nix) can expose .#<hostname> for nixos-anywhere to target.
HOSTNAME_NIX="$SCRIPT_DIR/hostnameconfig/${HOSTNAME}.nix"
if [[ ! -f "$HOSTNAME_NIX" ]]; then
  echo "==> Creating $HOSTNAME_NIX"
  mkdir -p "$SCRIPT_DIR/hostnameconfig"
  printf '{ networking.hostName = "%s"; }\n' "$HOSTNAME" > "$HOSTNAME_NIX"
fi

# Stage the age private key in a temp dir so nixos-anywhere can upload it to
# /var/lib/sops-nix/age-key.txt on the target — required for sops-nix to
# decrypt secrets (wifi PSK, user password) on first boot.
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
install -Dm600 "$AGE_KEY_FILE" "$TMP/var/lib/sops-nix/age-key.txt"

if [[ "$SKIP_NIXOS_ANYWHERE" -eq 0 ]]; then
  # Partition the disk (via disko), install the bootstrap NixOS config, and
  # reboot the target. Also generates hardware-configuration.nix locally.
  echo "==> Bootstrapping $HOSTNAME onto $TARGET_IP..."
  nixos-anywhere \
    --flake "$SCRIPT_DIR#${HOSTNAME}" \
    --generate-hardware-config nixos-generate-config "$SCRIPT_DIR/hardware-configuration.nix" \
    --extra-files "$TMP" \
    root@"${TARGET_IP}"

  echo "==> Waiting for machine to come back up..."
  until ssh \
      -o StrictHostKeyChecking=no \
      -o ConnectTimeout=5 \
      -o BatchMode=yes \
      root@"${TARGET_IP}" true 2>/dev/null; do
    printf '.'
    sleep 5
  done
  echo

  # Fix EFI boot order so the internal disk boots first, not the USB.
  # Identifies the correct "Linux Boot Manager" entry by matching the PARTUUID
  # of the ESP (/boot) against the device paths in efibootmgr -v output.
  echo "==> Fixing EFI boot order on ${TARGET_IP}..."
  ssh -o StrictHostKeyChecking=no root@"${TARGET_IP}" '
    ESP_PART=$(findmnt -no SOURCE /boot)
    PART_GUID=$(blkid -s PARTUUID -o value "$ESP_PART" | tr "[:upper:]" "[:lower:]")

    BOOTNUM=$(efibootmgr -v \
      | grep -i "Linux Boot Manager" \
      | grep -i "$PART_GUID" \
      | grep -oP "Boot\K[0-9]+" \
      | head -1)

    if [[ -z "$BOOTNUM" ]]; then
      echo "WARNING: could not identify correct EFI entry — boot order unchanged"
    else
      CURRENT_ORDER=$(efibootmgr | grep "^BootOrder:" | awk "{print \$2}")
      NEW_ORDER="${BOOTNUM},${CURRENT_ORDER//${BOOTNUM},/}"
      efibootmgr -o "$NEW_ORDER" >/dev/null
      echo "EFI boot order updated: Boot${BOOTNUM} (internal disk) is now first"
    fi
  '
else
  echo "==> Skipping nixos-anywhere deployment (--skip-nixos-anywhere)."
fi

# ── Phase 3: update local dotfiles ────────────────────────────────────────────
# Commit the machine-specific hardware + disk configs and flake entry into the
# dotfiles repo so the target can pull a complete, buildable config.

LOCAL_NIXOS="$HOME/.config/nixos"
LOCAL_GIT="git --git-dir=$HOME/.cfg --work-tree=$HOME"

echo "==> Updating local dotfiles config for $HOSTNAME..."

# Copy the freshly generated hardware config (kernel modules, CPU microcode, etc.)
mkdir -p "$LOCAL_NIXOS/hardwareConfig"
cp "$SCRIPT_DIR/hardware-configuration.nix" "$LOCAL_NIXOS/hardwareConfig/${HOSTNAME}-hw.nix"

# Copy the disko disk layout (partition table + LVM config) — the disko module
# on the target will use this to generate fileSystems.* at build time.
cp "$SCRIPT_DIR/disk-config.nix" "$LOCAL_NIXOS/hostnameConfig/${HOSTNAME}-disk.nix"

# Create a wrapper module that imports both configs and sets the hostname.
# This is what the dotfiles flake's nixosConfiguration for this host will import.
HOST_CONFIG="$LOCAL_NIXOS/hostnameConfig/${HOSTNAME}-config.nix"
if [[ ! -f "$HOST_CONFIG" ]]; then
  cat > "$HOST_CONFIG" << EOF
{ ... }:
{
  imports = [
    ../hardwareConfig/${HOSTNAME}-hw.nix
    ./${HOSTNAME}-disk.nix
  ];

  networking.hostName = "${HOSTNAME}";
  system.stateVersion = "25.11";
}
EOF
fi

# Patch the dotfiles flake.nix to add a nixosSystem entry for this hostname
# if one doesn't already exist.
FLAKE="$LOCAL_NIXOS/flake.nix"
if ! grep -q "${HOSTNAME} =" "$FLAKE" 2>/dev/null; then
  awk '
/nixosConfigurations\s*=\s*\{/ { inConfigs=1 }
inConfigs && /^    };/ && !done {
  print "      '"${HOSTNAME}"' = nixpkgs.lib.nixosSystem {"
  print "        system = \"x86_64-linux\";"
  print "        specialArgs = { inherit inputs; };"
  print "        modules = ["
  print "          inputs.disko.nixosModules.disko"
  print "          inputs.nix-index-database.nixosModules.nix-index"
  print "          ./hostnameConfig/'"${HOSTNAME}"'-config.nix"
  print "          ./configuration.nix"
  print "        ];"
  print "      };"
  done=1
}
{ print }
' "$FLAKE" > /tmp/flake.tmp && mv /tmp/flake.tmp "$FLAKE"
fi

# Stage and push all new/changed files so the target can pull them.
echo "==> Committing and pushing dotfiles..."
$LOCAL_GIT add \
  "$LOCAL_NIXOS/hardwareConfig/${HOSTNAME}-hw.nix" \
  "$LOCAL_NIXOS/hostnameConfig/${HOSTNAME}-disk.nix" \
  "$LOCAL_NIXOS/hostnameConfig/${HOSTNAME}-config.nix" \
  "$LOCAL_NIXOS/flake.nix"
if $LOCAL_GIT diff --cached --quiet; then
  echo "==> No dotfiles changes to commit, continuing..."
else
  $LOCAL_GIT commit -m "deploy: add ${HOSTNAME} nixos config"
  $LOCAL_GIT push
fi

# ── Phase 4: apply real config on target ──────────────────────────────────────
# Write a setup script to the target, then run it as a detached systemd unit
# so it survives the SSH disconnect that nixos-rebuild switch causes when it
# restarts dbus mid-apply.

echo "==> Writing setup script to ${TARGET_IP}..."
ssh -o StrictHostKeyChecking=no root@"${TARGET_IP}" 'cat > /tmp/nixos-setup.sh && chmod +x /tmp/nixos-setup.sh' << ENDSSH
#!/usr/bin/env bash
set -e
export PATH=/run/current-system/sw/bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Clone dotfiles bare repo via HTTPS (no SSH key needed for a public repo).
git clone --bare ${DOTFILES_REPO} /home/${DOTFILES_USER}/.cfg

# Checkout dotfiles into the home directory. If any files conflict, back them
# up to ~/.cfg-backup/ and retry.
conflicts=\$(git --git-dir=/home/${DOTFILES_USER}/.cfg --work-tree=/home/${DOTFILES_USER} checkout 2>&1 \
  | grep -E '^\s+' | awk '{print \$1}' || true)
if [[ -n "\$conflicts" ]]; then
  echo "\$conflicts" | while read -r f; do
    mkdir -p "/home/${DOTFILES_USER}/.cfg-backup/\$(dirname "\$f")"
    mv "/home/${DOTFILES_USER}/\$f" "/home/${DOTFILES_USER}/.cfg-backup/\$f"
  done
  git --git-dir=/home/${DOTFILES_USER}/.cfg --work-tree=/home/${DOTFILES_USER} checkout
fi
git --git-dir=/home/${DOTFILES_USER}/.cfg --work-tree=/home/${DOTFILES_USER} \
  config --local status.showUntrackedFiles no

chown -R ${DOTFILES_USER}:users /home/${DOTFILES_USER}

# Switch to the real NixOS configuration from dotfiles.
nixos-rebuild switch --flake /home/${DOTFILES_USER}/.config/nixos#${HOSTNAME}

echo "==> Setup complete."
ENDSSH

# Stop any leftover nixos-apply unit from a previous run to avoid a "unit
# already exists" error from systemd-run.
echo "==> Stopping previous nixos-apply service on ${TARGET_IP} (if present)..."
ssh -o StrictHostKeyChecking=no root@"${TARGET_IP}" '
  if systemctl list-units --all --no-legend nixos-apply.service 2>/dev/null | grep -q nixos-apply; then
    systemctl stop nixos-apply 2>/dev/null || true
    systemctl reset-failed nixos-apply 2>/dev/null || true
  fi
'

echo "==> Launching setup on ${TARGET_IP} (detached)..."
ssh -o StrictHostKeyChecking=no root@"${TARGET_IP}" \
  'systemd-run --unit=nixos-apply --no-block bash /tmp/nixos-setup.sh'

# Follow the journal on the target. The remote shell kills the tail and exits
# automatically once the nixos-apply unit finishes.
echo "==> Following logs (Ctrl-C is safe — setup continues on target)..."
ssh -o StrictHostKeyChecking=no root@"${TARGET_IP}" '
  journalctl -u nixos-apply -f --no-pager &
  JPID=$!
  while [[ "$(systemctl is-active nixos-apply 2>/dev/null)" =~ ^(active|activating)$ ]]; do
    sleep 2
  done
  sleep 3
  kill $JPID 2>/dev/null
  wait $JPID 2>/dev/null
  systemctl show nixos-apply --property=Result --value 2>/dev/null || echo unknown
' || true
echo

RESULT=$(ssh -o StrictHostKeyChecking=no root@"${TARGET_IP}" \
  'systemctl show nixos-apply --property=Result --value 2>/dev/null || echo unknown')

if [[ "$RESULT" == "success" ]]; then
  echo "==> Done. $HOSTNAME is running its real config."
  echo "    SSH in: ssh ${DOTFILES_USER}@${TARGET_IP}"
else
  echo "ERROR: nixos-apply finished with result: $RESULT"
  echo "  Check logs: ssh root@${TARGET_IP} 'journalctl -u nixos-apply'"
  exit 1
fi
