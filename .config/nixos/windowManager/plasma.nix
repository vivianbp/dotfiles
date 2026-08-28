{ pkgs, ... }:

{
  # Enable the Plasma 5 Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
}
