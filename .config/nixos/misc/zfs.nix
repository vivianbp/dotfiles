{ config, pkgs, ... }:
{
  ##### zfs #####
  # imports = [  ];


  
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  assertions = [
    {
      assertion = config.networking.hostId != null;
      message = "zfs.nix requires networking.hostId to be set on the host (e.g. head -c4 /dev/urandom | od -A none -t x4)";
    }
  ];

  environment.systemPackages = with pkgs; [
    zfs
  ];
}
