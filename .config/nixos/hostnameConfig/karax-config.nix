{ pkgs, ... }:
{
  imports = [

  ];

  networking.hostName = "karax";

  # VA-API hardware video decode for the Intel HD 620 (Kaby Lake)
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];
  environment.systemPackages = with pkgs; [ libva-utils ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  boot.kernelParams = [ "resume_offset=4294656" ];
  boot.resumeDevice = "/dev/mapper/nixos--vg-root";
  swapDevices = [{ device = "/var/swapfile"; size = 24 * 1024; }];

  #IIO stands for the Industrial I/O subsystem of the Linux Kernel
  #I dont actually think this machine has one anymore ()
  hardware.sensor.iio.enable = true; 
  
  programs.claude-dim.enable = true;
  
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
