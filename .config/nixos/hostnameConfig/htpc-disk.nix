# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      # device = lib.mkDefault "/dev/nvme0n1";
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02"; # BIOS boot partition 
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00"; # EFI System
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          recoverynix = {
            name = "recovnix";
            size = "20G";
            content = {
              type = "filesystem"; 
              format = "ext4";
            };
          };
          lvmpart = {
            name = "lvmpart";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "50%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
          home = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
