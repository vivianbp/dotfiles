{ config, pkgs, ... }:
# Smart card (JavaCard) support + sudo via FIDO2.
#
# The card runs FIDO2Applet (github.com/BryanJacobs/FIDO2Applet), installed with
# GlobalPlatformPro (`gp`, full path: your shell aliases gp=git push).
# libfido2 in nixpkgs is built with PC/SC, so contact readers show up as pcsc://slotN.
#
# Per host, register the card and put the line in that host's config:
#   pamu2fcfg -N -o pam://<host> -i pam://<host> -u vboysepe
#   environment.etc."u2f_mappings".text = "<output>";
let
  origin = "pam://${config.networking.hostName}";
in
{
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    pcsc-tools # pcsc_scan
    global-platform-pro # gp
    libfido2 # fido2-token
    pam_u2f # pamu2fcfg
  ];

  # pcscd runs as user `pcscd`, but logind's uaccess ACL can leave `group::---`
  # on the reader's USB node, giving pcscd LIBUSB_ERROR_ACCESS. Grant it explicitly.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_SMARTCARD_READER}=="1", RUN+="${pkgs.acl}/bin/setfacl -m g:pcscd:rw $env{DEVNAME}"
  '';

  # Card + FIDO2 PIN instead of the password for sudo; without the card the
  # password prompt still works. The global security.pam.u2f.enable is left off
  # on purpose: it would turn the card on for every PAM service (login, greeter, lock).
  security.pam.u2f = {
    control = "sufficient";
    settings = {
      cue = true;
      pinverification = 1;
      authfile = "/etc/u2f_mappings"; # root-owned via environment.etc, not ~/.config/Yubico
      inherit origin;
      appid = origin;
    };
  };
  security.pam.services.sudo.u2f.enable = true;
}
