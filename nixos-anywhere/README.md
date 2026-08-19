# nixos-anywhere flake

Personal NixOS configuration flake for reproducible system deployments. It builds a bootable installer ISO and deploys the real config to bare-metal/VM targets via [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) + [disko](https://github.com/nix-community/disko), then hands off to a separate personal [dotfiles](https://github.com/violetbp/dotfiles) repo for the machine's actual day-to-day configuration.

The two-phase idea:

1. **Boot the ISO** ([`iso.nix`](iso.nix)) on the target machine. It's a minimal installer with SSH, NetworkManager, and Wi‑Fi presets baked in.
2. **Run `deploy.sh`** from this repo. It partitions/formats the disk, installs a minimal bootstrap NixOS config from this flake, then pulls down the real dotfiles config and switches to it — all in one shot.

## Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | `nixpkgs-unstable` |
| `disko` | Declarative disk partitioning |
| `sops-nix` | Secret management via age (Wi‑Fi PSK, user password) |
| `nixos-facter-modules` | Experimental hardware-detection alternative to `nixos-generate-config` |

## Outputs (`nixosConfigurations`)

| Attribute | Purpose |
|-----------|---------|
| `<hostname>` | **Auto-generated** — one per `.nix` file in [`hostnameconfig/`](hostnameconfig/) (e.g. `kerrigan`, `talandar`). `deploy.sh` creates these automatically. |
| `iso` | Minimal install CD + [`iso.nix`](iso.nix) — build this to get the flashable USB image. |
| `generic` | Bootstrap config with no hostname set yet — a fallback target when you haven't created a `hostnameconfig/` entry. |
| `generic-nixos-facter` | Experimental: like `generic`, but hardware is described via `nixos-facter`'s `facter.json` instead of `nixos-generate-config`. |
| `recovery` | Alternate layout intended for recovery-style installs — **currently broken**, it imports `./configurationrecover.nix`, which doesn't exist in this repo yet. |

Every hostname config (plus `generic`) shares `bootstrapModules`: `disko`, `sops-nix`, [`initialconfiguration.nix`](initialconfiguration.nix), and `hardware-configuration.nix`.

## Prerequisites

- `secrets/secrets.yaml` exists and is sops-encrypted (see [Secrets](#secrets) below).
- `~/.config/sops/age/keys.txt` contains your age private key.
- `nixos-anywhere` is on `PATH` (`nix shell github:nix-community/nixos-anywhere`).

## Build the USB image

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

Result is under `result/iso/` — write it to a USB drive (`dd`, Fedora Media Writer, etc.) and boot the target from it. Once booted, get it on the network (Ethernet, or one of the `networkPresets.wifiNetworks` baked into [`iso.nix`](iso.nix) — `nmtui` also works for anything else) and note its IP.

## Deploy a new machine

`deploy.sh` is the main entry point:

```bash
./deploy.sh <target-ip> <hostname>
# Example: ./deploy.sh 192.168.1.50 kerrigan
```

It runs four phases:

1. **Bootstrap** — creates `hostnameconfig/<hostname>.nix` if missing, then runs `nixos-anywhere` to partition (disko), format, and install the bootstrap config from this flake. The age key is uploaded via `--extra-files` so sops-nix can decrypt secrets on first boot. After reboot, it fixes the EFI boot order so the internal disk boots before the installer USB.
2. **Update dotfiles** — copies the freshly generated `hardware-configuration.nix` and `disk-config.nix` into the local dotfiles checkout (`~/.config/nixos`), creates a per-host wrapper module there, patches the dotfiles `flake.nix` to add a `nixosConfigurations.<hostname>` entry, and pushes the commit.
3. **Apply real config** — SSHes in, clones the dotfiles bare repo to `~/.cfg`, and runs `nixos-rebuild switch --flake ~/.config/nixos#<hostname>` as a detached `systemd-run` unit (`nixos-apply`) so it survives the SSH/dbus restart mid-switch.
4. **Follow logs** — tails `journalctl -u nixos-apply` on the target; Ctrl‑C is safe, the unit keeps running.

Flags:

- `--skip-nixos-anywhere` — skip phase 1 and go straight to the dotfiles phase (for a machine that's already partitioned/installed). `deploy-failed.sh` is a shorthand for this — use it to resume after a first attempt fails partway through.

### push-dotfiles.sh

After a fresh deploy, the target's dotfiles checkout points at the HTTPS remote (no auth needed to clone a public repo). Run this once you want to push changes back from the target:

```bash
./push-dotfiles.sh <target-ip>
```

Switches the `~/.cfg` remote to SSH and pushes `main`. Requires `ssh -A` agent forwarding so GitHub auth works without a key living on the target.

## Manual nixos-anywhere (without deploy.sh)

```bash
nixos-anywhere --flake .#<hostname> \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  root@<target-ip>
```

Facter-based experimental variant:

```bash
nixos-anywhere --flake .#generic-nixos-facter \
  --generate-hardware-config nixos-facter ./facter.json \
  root@<target-ip>
```

## Module reference

**Deployable modules (wired into `flake.nix`):**

- [`iso.nix`](iso.nix) — live installer: user/root SSH keys, OpenSSH, NetworkManager, `networkPresets.wifiNetworks`, binary cache substituters, install tooling. GUI apps were intentionally left out to keep the ISO small.
- [`initialconfiguration.nix`](initialconfiguration.nix) — installed system base: disko + network imports, systemd-boot, sops-nix secrets (Wi‑Fi PSK templated into a `.nmconnection` file, hashed user password), OpenSSH with root login enabled (required for `nixos-anywhere` to connect), user account, SSH keys.
- [`disk-config.nix`](disk-config.nix) — disko GPT layout on `/dev/sda`: BIOS boot stub → 500M EFI System Partition (`/boot`) → 20G recovery partition (unused by default) → LVM PV filling the rest. The `pool` volume group splits into `root` (50% of free space) and `home` (remaining free space), both ext4.
- [`network.nix`](network.nix) — defines `networkPresets.wifiNetworks`, which writes NetworkManager `.nmconnection` files for predefined Wi‑Fi networks. Shared between the ISO and the installed system.
- [`digitalocean.nix`](digitalocean.nix) — DigitalOcean target module (`digital-ocean-config.nix` + cloud-init datasource config). Not currently wired into a flake output — add it to a host's `modules` list when deploying to a droplet.

**Personal laptop config (not part of this flake's outputs):** [`configuration.nix`](configuration.nix), [`programs.nix`](programs.nix), [`starship.nix`](starship.nix), [`laptop.nix`](laptop.nix), [`misc.nix`](misc.nix) — the day-to-day desktop/laptop config (hibernation, firewall, Bluetooth, PipeWire, Catppuccin theming, Zsh/Starship, package list). These live here for reference/reuse but are applied through the separate dotfiles flake during phase 3 of `deploy.sh`, not through `flake.nix` in this repo.

## Secrets

Managed with [sops-nix](https://github.com/Mic92/sops-nix); recipients are configured in [`.sops.yaml`](.sops.yaml).

```bash
age-keygen -o ~/.config/sops/age/keys.txt      # generate a key if you don't have one
cp secrets/secrets.yaml.example secrets/secrets.yaml
sops -e -i secrets/secrets.yaml                # encrypt in place
sops secrets/secrets.yaml                      # edit later
```

`secrets.yaml` holds `ssh-authorized-key` and `wifi-psk`. During `nixos-anywhere` bootstrap, the age private key is uploaded to `/var/lib/sops-nix/age-key.txt` on the target so it can decrypt these at activation time.

**Before sharing or publishing this repo**, replace the hardcoded SSH public keys in [`iso.nix`](iso.nix) and [`initialconfiguration.nix`](initialconfiguration.nix), the Wi‑Fi SSID/PSK preset in [`iso.nix`](iso.nix), and the binary-cache host/keys tied to `kerrigan`. Never commit `secrets/secrets.yaml` unencrypted.
