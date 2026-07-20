#### NIRI + ####
{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  environment = {
    pathsToLink = [ "/libexec" ];
    sessionVariables.NIXOS_OZONE_WL = "1"; # Apply Wayland flags to Electron apps where necessary
  };

  programs = {
    niri.enable = true;
    niri.package = inputs.niri-flake.packages.${pkgs.system}.niri-unstable;
    # waybar.enable = true;
    # waybar.package = "github:Nitepone/Waybar?ref=dev/niri-taskbar";
    dconf.enable = true;
  };
  # nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];
  # programs.niri.package = pkgs.niri-unstable;
  environment.systemPackages = with pkgs; [
    # inputs.waybar.packages.${pkgs.system}.default
    xdg-desktop-portal-gtk
    fuzzel
    # swaylock
    wayland-utils
    xwayland-satellite
    adwaita-icon-theme
    yaru-theme
    swaybg
    # mako
    #betterlockscreen #prettyier might be nice
  ];

  # this is needed for the application icons to load in. if theres an issue in the future I probably need a local to my user path set up or smth
  systemd.user.services.waybar.serviceConfig = {
    Environment = "\"PATH=$PATH:/run/current-system/sw/bin\"";
  };

  # tty service config
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  services = {
    
    greetd = {
      enable = true;
      settings = {
        # services.displayManager.defaultSession = "steam-gamescope";

        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
          user = "greeter";
        };
        initial_session = { # autologin with full disc encryption is based
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
          user = "vboysepe";
        };
      };
    };



    # GTK theme config
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };
  };
}
