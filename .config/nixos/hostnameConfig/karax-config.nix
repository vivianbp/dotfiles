{ pkgs, ... }:
{
  imports = [

  ];

  networking.hostName = "karax";

  # VA-API hardware video decode for the Intel HD 620 (Kaby Lake)
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];
  environment.systemPackages = with pkgs; [ 
    libva-utils
    ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  # Windows 11 lives on nvme0n1p3; its bootmgfw.efi is on the shared ESP (/boot)
  boot.loader.timeout = 10;
  boot.loader.systemd-boot.extraEntries."windows.conf" = ''
    title Windows 11
    efi /EFI/Microsoft/Boot/bootmgfw.efi
    sort-key o_windows
  '';

  boot.kernelParams = [ "resume_offset=4294656" ];
  boot.resumeDevice = "/dev/mapper/nixos--vg-root";
  swapDevices = [{ device = "/var/swapfile"; size = 24 * 1024; }];

  #IIO stands for the Industrial I/O subsystem of the Linux Kernel
  #I dont actually think this machine has one anymore ()
  hardware.sensor.iio.enable = true; 
  
  # programs.claude-dim.enable = true;

  # javacard: see ../misc/smartcard.nix. Card credential for sudo
  # (pamu2fcfg -N -o pam://karax -i pam://karax -u vboysepe; public data only):
  environment.etc."u2f_mappings".text = ''
    vboysepe:hyfZ9YjsyaPy0bFAIFWFnZdubDGCLkVCB0BW4KgQG1y91yorgARKUAk4Irg9qhrmrCawBe6lpMSm6RwDfgvMt2z9vdQRy/RpahqM3I4jBv7p3nomFOBn8wuKzG8l1S8o6Ecle7LLROAA/MIERS1Bxw==,Z+o6XgZ1CWq9mluKXwlcurQUWmmdYU0zo97+DZKDRo6ZDax+Vlr5kVKwsxJv/sAq5MW+Tb3jwuANVV4RBG+8zg==,es256,+presence+pin:WEiFmk8UEs7+OFDbbiMai8v5F/mA4UjxIovcw8dj+eEjbanZqCERl2E/w2Fk190AjPLgVUMPTE3W3ZH90umeHw==,KN7jiRBkuluT9WPZV4JfTCV8C6hInmvwTzrdN6rdHlA7BuPq7v7uMZLrQ4Q/HR0i8EJ9WqeEYmO2WB6qRUwK6w==,es256,+presence+pin
  '';


  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p5";
      preLVM = true;
    };
  };
  boot.initrd.availableKernelModules = [
    # trimmed irrelevant ones
    "thinkpad_acpi"
  ];
  services.ratbagd.enable = true;
  
  # virtualisation.virtualbox.host.enable = false;
  # users.extraGroups.vboxusers.members = [ "vboysepe" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  system.stateVersion = "21.11";
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;




  ### synergy
  # services.synergy.server = {
  #   enable = true;
  # };


  networking.firewall.allowedUDPPorts = [ 4242 ];
  home-manager.users.vboysepe.imports = [
    ../homemanager/lanMouse.nix
    ../homemanager/niriMouseGestures.nix
  ];

}
