# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  # inputs,
  # refind,
  ...
}:

{
  imports = [
    ./programs.nix
    ./starship.nix
    ./laptop.nix
    ./misc.nix
  ];
  # nix.settings = { 
  #   download-buffer-size = 524288000; # 500 MiB
  #  }; 

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # # hibernation stuff
  # boot.kernelParams = [
  #   # "resume=/dev/mapper/nixos--vg-root"
  #   "resume_offset=24887296"
  # ];
  swapDevices = [
    {
      device = "/var/swapfile";
      size = 16 * 1024; # 16GB in MB
    }
  ];
  # boot.resumeDevice = "/dev/mapper/nixos--vg-root";

  xdg.portal.enable = true;

  # services.openafsClient.enable = true;
  # services.openafsClient.cellName = "cs.cmu.edu";

  # # Container/VM
  # virtualisation.lxd.enable = false;
  # virtualisation.docker.enable = true;

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

    firewall.enable = true;
    nftables.enable = true;
    # systemd.services.NetworkManager = {
    #   wantedBy = lib.mkForce [ "multi-user.target" ];
    # };

    extraHosts = ''
      #10.147.19.1    orlana
      #10.147.19.164  nova
      10.0.0.125      plex
      10.241.172.176  artemis
      10.0.0.3        orlanahome
      10.0.0.7        haos
      10.0.1.177      kerrigan
         '';

  };
  users.users.root.openssh.authorizedKeys.keys =  [
    # change this to your ssh key
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEM5j07kBTjfN6kAShtpux5oxHUtQPQiQyxUNKzV6Ytrj6DlFD/3UXkilagDX2zEPzDOLBp59WTpIMDVp+Jaqf5Iv1WYNXQPN5qNbHutCiDJGwYaCoynUW0dsG419eZgUsKc3tyQucKXRnopzJ0xBJN4k+JU4eHc6dk4Jgfp8fNh7tN5onuTjcHnfeKE9GR/tMWoNxz+wxo9ymBsu/3Jiu/NJGNH9437Kke+w7IaRq8tbxZSsrEm8XgR/QW8iOJog2JOuBN1eqrGtJ6x5xJPZS753akzCVJXFIhiwNbhNOtJKq9Glh6aOFlMF/lKLSUxPwQpmnr9LeEFSdn4JQo9/eYPOvFz0cjjubFXFlhZRu+PErkYBV5Fn+0LCXG+aic99eK6Jvu8k7dKPv7ROCTZdPSS1IOzRalUKoB6ZuAKiYFVafNv6qUjPUnVP5J69Po03nDtzM/E+BwgquW8SJrsmxebYQzn4TzULmKPYOcGwJsrmQKR2jDyK5JnolJUYmAbs= vboysepe@terra"
  ];
  environment.sessionVariables.DEFAULT_BROWSER = "/var/lib/flatpak/exports/bin/app.zen_browser.zen";

  # boot.loader.refind = {
  #           enable = true;
  #           maxGenerations = 10;
  #       };



  #laptop stuff
  # services.thermald.enable = true;
  # powerManagement.enable = true;
  # powerManagement.powertop.enable = true;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "performance";#powersave";
  #     turbo = "auto";
  #   };
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #   };
  # };

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    # SleepOperation = "suspend";
    # IdleAction = "suspend";
    extraConfig = ''
      LidSwitchIgnoreInhibited=yes
    '';
    powerKey = "hibernate";
    # extraConfig = ''
    #   HandlePowerKey=ignore
    #   HandleSuspendKey=ignore
    #   HandleHibernateKey=ignore
    # '';
  };
  # services.acpid.enable = true;

  services.openssh = {
    #enable = true;
    enable = false;
    settings = {
      permitRootLogin = "no";
    };
  };

  # Set your time zone.
  # time.timeZone = "America/New_York";
  time.timeZone = "US/Pacific";

  ###### Printers ######
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip pkgs.canon-cups-ufr2 ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };


  ###### Sound ######
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
  ###### BT ######
  services.blueman.enable = true;
  # hardware.bluetooth = {
  #   enable = true;
  #   settings = {
  #     General = {
  #       Enable = "Source,Sink,Media,Socket";
  #     };
  #   };
  # };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "bredr"; # Fix frequent Bluetooth audio dropouts
        Experimental = true;
        FastConnectable = true;
        Enable = "Source,Sink,Media,Socket";

      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

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
    ]; # Enable ‘sudo’ for the user.
  };
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [ 
        { command = "${pkgs.nixos-rebuild-ng}/bin/nixos-rebuild-ng"; options = [ "NOPASSWD" ]; } 
        { command = "${pkgs.nix}/bin/nix-collect-garbage"; options = [ "NOPASSWD" ]; }
        ];
    }
  ];
  hardware.graphics.enable = true;
}
