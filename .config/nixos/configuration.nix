# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  # refind,
  ...
}:

{
  imports = [
    ./programs.nix
    ./starship.nix
    ./misc.nix
    ./printers.nix
  ];
  # stdenv.hostPlatform.system = inputs.system;


  
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelParams = [ "mitigations=off" ];

  nix = {
    settings.download-buffer-size = 500000000;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    settings = {
      substituters = [
        "http://kerrigan:5000?priority=10"  # local harmonia cache — prefer over upstream
        "https://cache.nixos.org"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "kerrigan.local:fg3tlyeJqGWEzz355TcSE6zuEQmm137FiSEjLPAaZoQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };



  ###### Boot ######
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    grub.useOSProber = true;
    efi.canTouchEfiVariables = true;
  };

  ###### Networking ######
  networking = {
    networkmanager.enable = true; # enables wireless support via networkmanager (nmcli and nmtui)
    # search = [ "alias.cs.cmu.edu" "cs.cmu.edu" "ri.cmu.edu cmu.edu" ];

    firewall.allowedUDPPortRanges = [
      {
        from = 32768;
        to = 60999;
      }
    ]; # google cast firewall rules

    firewall.allowedTCPPorts = [ 8080 ];
    firewall.enable = true;
    nftables.enable = true;
    # systemd.services.NetworkManager = {
    #   wantedBy = lib.mkForce [ "multi-user.target" ];
    # };

    extraHosts = ''
      # 10.147.19.1   orlana
      # 10.147.19.164 nova
      10.0.0.215      plex
      10.241.172.176  artemis
      10.0.0.3        orlanahome
      10.0.0.7        haos
      10.0.1.177      kerrigan
    '';

  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
  users.users.root.openssh.authorizedKeys.keys =  [
    # change this to your ssh key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEM5j07kBTjfN6kAShtpux5oxHUtQPQiQyxUNKzV6Ytrj6DlFD/3UXkilagDX2zEPzDOLBp59WTpIMDVp+Jaqf5Iv1WYNXQPN5qNbHutCiDJGwYaCoynUW0dsG419eZgUsKc3tyQucKXRnopzJ0xBJN4k+JU4eHc6dk4Jgfp8fNh7tN5onuTjcHnfeKE9GR/tMWoNxz+wxo9ymBsu/3Jiu/NJGNH9437Kke+w7IaRq8tbxZSsrEm8XgR/QW8iOJog2JOuBN1eqrGtJ6x5xJPZS753akzCVJXFIhiwNbhNOtJKq9Glh6aOFlMF/lKLSUxPwQpmnr9LeEFSdn4JQo9/eYPOvFz0cjjubFXFlhZRu+PErkYBV5Fn+0LCXG+aic99eK6Jvu8k7dKPv7ROCTZdPSS1IOzRalUKoB6ZuAKiYFVafNv6qUjPUnVP5J69Po03nDtzM/E+BwgquW8SJrsmxebYQzn4TzULmKPYOcGwJsrmQKR2jDyK5JnolJUYmAbs= vboysepe@terra"
  ];


  services.openssh = {
    #enable = true;
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };
  programs.ssh.extraConfig = ''
    Host 10.0.* kerrigan
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
  '';

  # Set time zone.
  # time.timeZone = "America/New_York";
  time.timeZone = "US/Pacific";


  ###### User ######
  users.users.vboysepe = {
    isNormalUser = true;
    home = "/home/vboysepe";
    shell = pkgs.zsh;
    createHome = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "disk"
      "networkmanager"
      "lxd"
      "mlocate"
      "adbusers"
      "dialout" #next two are for serial stuff
      "uucp"
      "ydotool"
    ]; 
  };
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [ 
        { command = "${pkgs.nix}/bin/nix-collect-garbage"; options = [ "NOPASSWD" ]; }
        ];
    }
  ];
  hardware.graphics.enable = true;
}
