{ ... }:
{
  imports = [
    ./printers.nix
    ./misc/audio.nix
  ];
  xdg.portal.enable = true;


  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  services = {
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    libinput.touchpad.naturalScrolling = true;
  };
  environment.sessionVariables.DEFAULT_BROWSER = "/var/lib/flatpak/exports/bin/app.zen_browser.zen";
  environment.sessionVariables.DIRENV_LOG_FORMAT = "";
}
