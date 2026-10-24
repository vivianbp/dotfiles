# NixOS module: wires home-manager into the system build.
# Import this from a host's module list in flake.nix (not from configuration.nix —
# server hosts don't use home-manager).
{ inputs, pkgsUnstable, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs pkgsUnstable; };
    users.vboysepe.imports = [ ../home.nix ];
  };
}
