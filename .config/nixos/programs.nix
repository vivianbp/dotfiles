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
      polkitPolicyOwners = [ "yourUsernameHere" ];
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
    kdePackages.plasma-workspace    
    anki
    ansible
    # inputs.humble-manager.packages.${pkgs.stdenv.system}.humble-manager
    arandr # gui diplay manager
    autoconf # make i think?
    automake
    bashmount
    bat
    brightnessctl
    cliphist
    clang-tools
    coreutils-full
    claude-code
    claude-monitor
    dig
    discord
    dgop # another top replacement
    direnv
    bolt-launcher # runescape
    efibootmgr
    emacs
    feh # image viewer
    firefox
    gcc
    git
    gjs
    glib
    geeqie
    google-chrome
    gparted
    gnome-disk-utility
    ghostty
    htop
    fontforge-gtk
    imagemagick
    inotify-tools
    jdk17_headless
    jq
    kdePackages.kate
    kitty
    krb5
    libreoffice
    # lutris
    maim # screenshots
    nano
    nix-direnv
    nixd
    nautilus
    ncdu
    nemo-with-extensions
    nemo-preview
    bluetui
    bluez
    hyfetch
    neovim
    nixos-anywhere
    libnotify
    kicad
    networkmanagerapplet
    nix-prefetch-scripts
    nixfmt
    nnn
    ntfs3g
    obsidian
    openconnect
    p3x-onenote
    pamixer # volume
    pavucontrol # gui sound manager from pulseaudio
    playerctl
    plex-desktop
    pciutils
    prismlauncher
    python313
    rsyslog
    rquickshare
    # rustup in dev shells
    runelite # cuz i love my girlfriends
    samba
    screen
    service-wrapper
    signal-desktop
    slack
    sops
    stow    
    nixfmt
    syslinux
    tmux
    transmission_4-qt
    udiskie
    udisks2
    unzip
    usbutils
    vim
    vlc
    vscode
    wget
    which
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    xclip
    xprop
    zip
    zoom-us
    zsh
    #  (import "./remctl.nix")
    #  nushell
    #  mlocate defined in service
    #  geticons    # CLI tool for locating icons
    #  (import (fetchTarball "channel:nixos-unstable") {}).polymc
    pkgsUnstable.telegram-desktop
    pkgsUnstable.pangolin-cli
    pkgsUnstable.code-cursor
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
