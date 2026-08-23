##
## Programs etc, that can be specified easily
##

{
  config,
  pkgs,
  inputs,
  pkgsUnstable,
  ...
}:
{

  nixpkgs.config = {
    allowUnfree = true;
  };

  # this allows you to access `pkgsUnstable` anywhere in your config https://discourse.nixos.org/t/mixing-stable-and-unstable-packages-on-flake-based-nixos-system/50351/4
  _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };

  programs = {
    nix-index-database.comma.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true; # caches nix develop shells so they load instantly
    };
    steam.enable = true;
    steam.package = pkgs.steam.override {
      extraArgs = "-system-composer";
    };
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      uv
    ];

    ###### 1password ######

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "vboysepe" ];
    };

  };
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        vivaldi-bin
        wavebox
      '';
      mode = "0755";
    };
  };

  ###### Mass Packages ######

  environment.systemPackages = with pkgs; [

    ###### Development / CLI Tooling ######
    ansible
    autoconf 
    automake
    bat
    clang-tools
    coreutils-full
    claude-code
    claude-monitor
    dig
    direnv
    gcc
    git
    gjs
    glib
    jdk17_headless
    jq
    krb5
    nix-direnv
    nixd
    nix-prefetch-scripts
    nixfmt
    nixos-anywhere
    python313
    sops
    stow
    tmux
    screen
    service-wrapper
    which
    # node, esphome, rustup, etc in dev shells

    ###### Editors ######
    emacs
    nano
    neovim
    vim
    vscode
    kdePackages.kate

    ###### System Administration / Disk & Storage ######
    bashmount
    efibootmgr
    gparted
    gnome-disk-utility
    ncdu
    ntfs3g
    samba
    udiskie
    udisks2
    usbutils
    pciutils
    bluetui
    bluez
    dgop # another top replacement
    htop
    rsyslog

    ###### Networking ######
    networkmanagerapplet
    openconnect
    wget
    rquickshare

    ###### File Management ######
    nautilus
    nemo-with-extensions
    nemo-preview
    geeqie
    feh # image viewer
    maim # screenshots

    ###### Media / Graphics ######
    imagemagick
    fontforge-gtk
    kicad
    playerctl
    pamixer # volume
    pavucontrol # gui sound manager from pulseaudio
    vlc
    transmission_4-qt
    # plex-desktop

    ###### Web Browsers ######
    firefox
    google-chrome

    ###### Communication / Chat ######
    discord
    signal-desktop
    slack
    zoom-us

    ###### Productivity / Office ######
    libreoffice
    obsidian
    anki
    p3x-onenote

    ###### Gaming ######
    bolt-launcher # runescape
    prismlauncher
    runelite # cuz i love my girlfriends
    # lutris

    ###### Clipboard / Notifications ######
    cliphist
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    xclip
    libnotify
    xprop

    ###### Terminals ######
    ghostty
    kitty

    ###### Shell ######
    zsh
    nnn

    ###### Misc Utilities ######
    # arandr # gui diplay manager not useful anymore
    brightnessctl
    inotify-tools
    hyfetch
    unzip
    zip
    syslinux

    ###### Disabled / Notes ######
    # inputs.humble-manager.packages.${pkgs.stdenv.system}.humble-manager
    #  (import "./remctl.nix")
    #  nushell
    #  mlocate defined in service
    #  geticons    # CLI tool for locating icons
    #  (import (fetchTarball "channel:nixos-unstable") {}).polymc

    ###### Unstable Channel (pkgsUnstable) ######
    pkgsUnstable.telegram-desktop
    pkgsUnstable.pangolin-cli
    # pkgsUnstable.code-cursor
    pkgsUnstable.noctalia-shell
    # pkgsUnstable.esphome
    pkgsUnstable.opencode

  ];


  fonts.packages = with pkgs; [
    nerd-fonts.recursive-mono
  ];

  services = {
    gvfs = {
      # this enables network fileshares such as samba to be used with nemo but doesnt seem to work :(
      enable = true;
      # package = pkgs.gnome.gvfs;
    };
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
    };
    # tailscale.enable = true;
    # zerotierone.enable = true;
    power-profiles-daemon.enable = true; # waybar needs this
    upower = {
      enable = true;
      criticalPowerAction = "HybridSleep";
      percentageLow = 14;
      usePercentageForPolicy = true;
    };
    geoclue2.enable = true;
  };
}
