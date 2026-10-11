{ ... }:
{
  imports = [
    ../hardwareConfig/amdroidtv-hw.nix
    ./amdroidtv-disk.nix
  ];

  networking.hostName = "amdroidtv";
  system.stateVersion = "25.11";
}
