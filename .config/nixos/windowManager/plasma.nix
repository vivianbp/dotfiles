{ pkgs, ... }:

{
  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
}
