{ ... }:
{
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
    connect-timeout = 1
    fallback = true
  '';
  nix.buildMachines = [{
    hostName = "kerrigan";
    system = "x86_64-linux";
    sshUser = "nix-ssh";
    sshKey = "/home/vboysepe/.ssh/ans";
    maxJobs = 8;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  }];
}
