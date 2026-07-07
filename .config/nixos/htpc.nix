{ config, lib, pkgs, inputs, ... }:
let
  plasmaBigscreenPkg = inputs.plasma-bigscreen.packages.x86_64-linux.plasma-bigscreen;
in
{
  # services.desktopManager.plasma6.enable = true;

  imports = [
    ./windowManager/plasma.nix
  ];
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    sessionPackages = [ plasmaBigscreenPkg ];
  };
  programs.ydotool.enable = true;


  environment.systemPackages =
    let
      firefoxExe = lib.getExe pkgs.firefox;
      mkKiosk =
        name: url:
        pkgs.writeShellScriptBin name ''
          export XDG_RUNTIME_DIR=/run/user/$(id -u)
          export WAYLAND_DISPLAY=wayland-0
          export MOZ_ENABLE_WAYLAND=1
          exec ${firefoxExe} --kiosk '${url}' "$@"
        '';
    in
    [
      plasmaBigscreenPkg
      pkgs.kdePackages.plasma-workspace  # provides startplasma-wayland for the bigscreen session
      (pkgs.writeShellScriptBin "launch-mlb" ''
        qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.wakeup
        GAME_ID=$(${pkgs.curl}/bin/curl -sf \
          "https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=$(date +%Y-%m-%d)&teamId=136" \
          | ${pkgs.jq}/bin/jq -r '.dates[0].games[0].gamePk // empty')
        if [ -n "$GAME_ID" ]; then
          URL="https://www.mlb.tv/tv/g$GAME_ID"
        else
          URL="https://www.mlb.tv"
        fi
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        export WAYLAND_DISPLAY=wayland-0
        export MOZ_ENABLE_WAYLAND=1
        exec ${firefoxExe} --kiosk "$URL" "$@"
      '')
      (mkKiosk "launch-f1" "https://f1tv.formula1.com")
      (pkgs.writeShellScriptBin "htpc-launcher" ''
        qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.wakeup
        case "$SSH_ORIGINAL_COMMAND" in
          launch-mlb) exec launch-mlb ;;
          launch-f1)  exec launch-f1 ;;
          *) echo "Unknown command: $SSH_ORIGINAL_COMMAND" >&2; exit 1 ;;
        esac
      '')
      pkgs.kdePackages.discover
      pkgs.kdePackages.kcalc
      pkgs.kdePackages.kcharselect
      pkgs.kdePackages.kclock
      pkgs.kdePackages.kcolorchooser
      pkgs.kdePackages.kolourpaint
      pkgs.kdePackages.ksystemlog
      pkgs.kdePackages.sddm-kcm
      pkgs.kdiff3
      pkgs.kdePackages.isoimagewriter
      pkgs.kdePackages.partitionmanager
      pkgs.hardinfo2
      pkgs.wayland-utils
      pkgs.wl-clipboard
      pkgs.vlc
    ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig = {
      pipewire."99-silent-bell.conf" = {
        "context.properties" = {
          "module.x11.bell" = false;
        };
      };
    };
  };

  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
      ];
    };
  };

  users.users.vboysepe.openssh.authorizedKeys.keys = [
    
    ''command="htpc-launcher",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/NDQ5Cg+Nk2IMr+kxzGhHVDNk1ush+7jG+eiGmEQr1 root@haos''
  ];

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
}
