{ pkgs, ... }:
{
  nix.settings = {
    max-jobs = "auto";
    cores = 0;
    trusted-users = [ "root" "@wheel" "nix-ssh" ];
  };

  nix.sshServe = {
    enable = true;
    write = true;  # required for building, not just substituting
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEC8yYjYLEuvL5g59nE1WZxeGLWT0jbxzxDpo7ABjcYy root@blade"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEM5j07kBTjfN6kAShtpux5oxHUtQPQiQyxUNKzV6Ytrj6DlFD/3UXkilagDX2zEPzDOLBp59WTpIMDVp+Jaqf5Iv1WYNXQPN5qNbHutCiDJGwYaCoynUW0dsG419eZgUsKc3tyQucKXRnopzJ0xBJN4k+JU4eHc6dk4Jgfp8fNh7tN5onuTjcHnfeKE9GR/tMWoNxz+wxo9ymBsu/3Jiu/NJGNH9437Kke+w7IaRq8tbxZSsrEm8XgR/QW8iOJog2JOuBN1eqrGtJ6x5xJPZS753akzCVJXFIhiwNbhNOtJKq9Glh6aOFlMF/lKLSUxPwQpmnr9LeEFSdn4JQo9/eYPOvFz0cjjubFXFlhZRu+PErkYBV5Fn+0LCXG+aic99eK6Jvu8k7dKPv7ROCTZdPSS1IOzRalUKoB6ZuAKiYFVafNv6qUjPUnVP5J69Po03nDtzM/E+BwgquW8SJrsmxebYQzn4TzULmKPYOcGwJsrmQKR2jDyK5JnolJUYmAbs= vboysepe@terra" # karax ans key
    ];
  };

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "8G";
  nix.daemonCPUSchedPolicy = "batch";
  nix.daemonIOSchedClass = "idle";

  # nix.sshServe creates the nix-ssh user/group automatically
  # so you can remove the manual users.users.nix-ssh block

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
}
