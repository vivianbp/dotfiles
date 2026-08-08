##
## thunderbolt dock 
## If your Thunderbolt device does not work, execute `boltctl` in a terminal. 
## This will show you your connected devices, and their respective uuid. 
## In color terminals, it will show you if your device is authorized (green light) or not (orange light).
##
## For each device that is not authorized, execute boltctl enroll --chain UUID_FROM_YOUR_DEVICE. 

{
  config,
  pkgs,
  ...
}:
{
  services.hardware.bolt.enable = true;
}