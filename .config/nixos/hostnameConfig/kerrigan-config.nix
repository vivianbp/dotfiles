{ ... }:
{
  imports = [
    ../hardwareConfig/kerrigan-hw.nix
    ../hardwareConfig/kerrigan-disk.nix
  ];

  networking.hostName = "kerrigan";

  nix.settings.tarball-ttl = 86400; # cache flake inputs for 24h; prevents nix develop from hitting network on every remote build invocation
  
  
  
  ##### zfs #####
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "0b504b7c";  # head -c4 /dev/urandom | od -A none -t x4


  system.stateVersion = "25.11";
}
