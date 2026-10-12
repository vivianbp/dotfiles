{pkgs,  ... }:
{
  imports = [
    ../hardwareConfig/htpc-hw.nix
    ./htpc-disk.nix
  ];

  networking.hostName = "htpc";
  virtualisation.waydroid.enable = true;
  # Newer kernel versions may need
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Enable clipboard sharing
  environment.systemPackages = [ pkgs.wl-clipboard ];

  



  system.stateVersion = "26.05";
}
