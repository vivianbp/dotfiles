{ config, lib, pkgs, ... }: {
  # only one at a time

  # to enroll 
  # services."06cb-009a-fingerprint-sensor" = {                                 
  #   enable = true;                                                            
  #   backend = "python-validity";                                              
  # };   

  # to use
  services."06cb-009a-fingerprint-sensor" = {                                 
    enable = true;                                                            
    backend = "libfprint-tod";                                                
    calib-data-file = ./calib-data.bin;                
  };
  services.fprintd.enable = true;

}