#### NIRI + ####
{
  config,
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
    dconf.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    fuzzel
    wayland-utils
    xwayland-satellite
    adwaita-icon-theme
    yaru-theme
    swaybg
    # mako
    noctalia
    noctalia-greeter
  ];

  hardware.i2c.enable = true;

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
    displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        cursor.size = 24;
        keyboard.layout = "us";
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
        };
      };
      
    };


    greetd = {
      enable = true;
      settings = {
        # autologin only when the disk is encrypted (the LUKS passphrase is the real login)
        initial_session = lib.mkIf (config.boot.initrd.luks.devices != { }) {
          command = "${config.programs.niri.package}/bin/niri-session";
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
