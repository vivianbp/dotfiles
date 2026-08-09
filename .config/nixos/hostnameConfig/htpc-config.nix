{ ... }:
{
  imports = [
    ../hardwareConfig/htpc-hw.nix
    ./htpc-disk.nix
  ];

  networking.hostName = "htpc";
  system.stateVersion = "25.11";
}
