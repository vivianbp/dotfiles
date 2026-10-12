##
## Some stuff is only on laptops!
##

{
  config,
  pkgs,
  ...
}:
{


  programs = {
    
  };

  environment.systemPackages = with pkgs; [
    batsignal
  ];


  services = {
    logind = {
      settings.Login = {
        HandleLidSwitch  = "suspend-then-hibernate";
        HandlePowerKey   = "hibernate";
      };
      # extraConfig = ''
      #   LidSwitchIgnoreInhibited=yes
      # '';
      # SleepOperation = "suspend";
      # IdleAction = "suspend";
    };
  };

  
  # services.acpid.enable = true;


  ##### laptop stuff #####
  # services.thermald.enable = true;
  # powerManagement.enable = true;
  # powerManagement.powertop.enable = true;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "performance";#powersave";
  #     turbo = "auto";
  #   };
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #   };
  # };

  # services.xserver.libinput = {
  #   # clickMethod = "buttonareas";
  #   # disableWhileTyping = true;
  #   enable = true;
  #   # middleEmulation = true;
  #   tapping = true;

  #   additionalOptions = ''
  #     Option "PalmDetection" "on"
  #     Option "TappingButtonMap" "lmr"
  #   '';
  # };

  #libinput option is only for xserver?
  services.udev.extraHwdb = ''
  evdev:name:*:*
    LIBINPUT_ATTR_TAP_BUTTON_MAP=btn-lmr
'';
}
