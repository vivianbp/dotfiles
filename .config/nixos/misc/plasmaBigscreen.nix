##
## Plasma Bigscreen package, built from a local checkout that currently only
## exists on kerrigan (~/projects/plasmabigscreen). Guarded by pathExists so
## hosts without that checkout (e.g. htpc) evaluate fine and simply skip it.
##
{ pkgsUnstable, lib, ... }:
let
  projectFile = /home/vboysepe/projects/plasmabigscreen/plasma-bigscreen.nix;
in
lib.mkIf (builtins.pathExists projectFile) (
  let
    plasmaBigscreenPkg = pkgsUnstable.callPackage projectFile { };
  in
  {
    services.displayManager.sessionPackages = [ plasmaBigscreenPkg ];
    environment.systemPackages = [ plasmaBigscreenPkg ];
  }
)

# might need this 
# environment.systemPackages = with pkgs; [
#     kdePackages.plasma-workspace    
