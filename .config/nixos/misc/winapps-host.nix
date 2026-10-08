##
## WinApps host: Windows 11 in a dockur/windows container, reached over RDP from the LAN
## Password comes from sops (secrets/winapps.yaml, key winapps-password), decrypted with the host ssh key
##

{ config, inputs, ... }:
{
  sops.defaultSopsFile = ../secrets/winapps.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets.winapps-password = { };
  sops.templates."winapps.env".content = ''
    USERNAME=vivian
    PASSWORD=${config.sops.placeholder.winapps-password}
  '';

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.winapps = {
    image = "ghcr.io/dockur/windows:latest";
    environment = {
      VERSION = "11";
      RAM_SIZE = "8G";
      CPU_CORES = "4";
      DISK_SIZE = "64G";
    };
    environmentFiles = [ config.sops.templates."winapps.env".path ];
    # docker bypasses the nixos firewall, so bind to the LAN ip only
    ports = [
      "10.0.1.177:3389:3389/tcp"
      "10.0.1.177:3389:3389/udp"
      "10.0.1.177:8006:8006" # web console, to watch the install
    ];
    volumes = [
      "/var/lib/winapps/storage:/storage" # C: drive
      "${inputs.winapps}/oem:/oem:ro" # applies RemoteApp registry tweaks after install
    ];
    devices = [
      "/dev/kvm"
      "/dev/net/tun"
    ];
    capabilities = {
      NET_ADMIN = true;
      NET_RAW = true;
    };
    extraOptions = [ "--stop-timeout=120" ];
  };

  systemd.tmpfiles.rules = [ "d /var/lib/winapps/storage 0750 root root -" ];
}
