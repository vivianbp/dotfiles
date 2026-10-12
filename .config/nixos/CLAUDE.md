# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Dry-build a specific host (safe, no changes applied)
nixos-rebuild dry-build --flake .#karax
nixos-rebuild dry-build --flake .#blade
nixos-rebuild dry-build --flake .#terra
nixos-rebuild dry-build --flake .#tassadar
nixos-rebuild dry-build --flake .#kerrigan

# Apply configuration on the current machine
sudo nixos-rebuild switch --flake .#<hostname>

# Format Nix files
nixfmt *.nix **/*.nix

# Update flake inputs
nix flake update

# Update a single input
nix flake update nixpkgs
```

## Architecture Overview

This is a multi-host NixOS flake managing 5 machines. All systems are `x86_64-linux`.

### Hosts

| Host | Type | Notable Features |
|------|------|-----------------|
| `terra` | T495 laptop | AMD GPU, LUKS, actkbd/light for brightness |
| `tassadar` | Desktop | LUKS, actkbd/light |
| `karax` | ThinkPad laptop | Intel, LUKS, IIO sensors, niri WM, nix-index, catppuccin |
| `blade` | Desktop | Intel, NVIDIA (offload mode), disko, niri WM, catppuccin |
| `kerrigan` | Server | disko, acts as distributed build server for other hosts |

### Flake Structure

`flake.nix` defines all 5 `nixosConfigurations`. Each system receives `specialArgs = { inherit inputs; }` so all flake inputs are accessible in module files.

**Key inputs:** `nixpkgs` (25.11 stable), `nixpkgs-unstable`, `home-manager` (release-25.11), `niri-flake`, `disko`, `catppuccin`, `nix-index-database`, `claude-desktop`, `humble-manager`.

Several packages in `programs.nix` are pulled from `pkgsUnstable`: `telegram-desktop`, `code-cursor`, `noctalia-shell`, `opencode`.

### Module Composition

Each host config in `hostnameConfig/` imports a subset of:
- `../windowManager/niri.nix` — primary WM (karax, blade)
- `../configuration.nix` — shared base
- `../hardwareConfig/<host>-hw.nix` — generated hardware config
- `../buildClient.nix` — enables distributed builds to kerrigan
- `../buildServer.nix` — kerrigan only; exposes nix SSH serve

`configuration.nix` further imports `programs.nix`, `starship.nix`, `laptop.nix`, `misc.nix`, `printers.nix`.

### Per-host Starship Colors

Defined in `starship.nix` using `networking.hostName` to pick a color per host:
- `karax` → `#56b6c2`, `terra` → `#98c379`, `tassadar` → `#e06c75`, `blade` → `#e5c07b`

### Home-Manager

`home.nix` exists but is **not wired into the flake outputs**. It is referenced in comments only. The `homemanager/` directory contains `mimeApps.nix` and `noctalia.nix`. Hosts that do include home-manager (karax, blade) set it up via `home-manager.nixosModules.home-manager` in `flake.nix`.

### Distributed Builds

`buildClient.nix` configures `nix.distributedBuilds` pointing to kerrigan (SSH user `nix-ssh`, 8 jobs, `x86_64-linux` feature). `buildServer2.nix` enables `nix.sshServe` on kerrigan with authorized keys for blade and terra builders.

## Known Issues (from theres-a-lot-of-frolicking-moon.md)

- `configuration.nix` hardcodes karax-specific resume values (`resume_offset=4294656`, `boot.resumeDevice`) — these break other hosts' hibernation.
- `laptop.nix` is imported unconditionally from `configuration.nix`, so kerrigan (server) also gets lid/hibernate behavior.
- Desktop-only services (PipeWire, Bluetooth, XDG portals, gnome-keyring, libinput) are in the shared base config, applied to all hosts including kerrigan.
- `terra-config.nix` references `./windowManager.nix` which does not exist (likely should be `../windowManager/niri.nix` or `sway.nix`).
- `lib/overlays.nix` references flake inputs (`cowsay`, `niri-scratchpad-flake`, etc.) that are not declared in `flake.nix`.

The planned fix (documented in `theres-a-lot-of-frolicking-moon.md`) is to create a `desktop.nix` module and move desktop/laptop-specific imports out of the shared base.
