
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";   
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # dgop = {
    #   url = "github:AvengeMedia/dgop";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # claude-desktop.url = "github:aaddrick/claude-desktop-debian";

    # dankMaterialShell = {
    #   url = "github:AvengeMedia/DankMaterialShell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.dgop.follows = "dgop";
    # };
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    # waybar.url        = "github:Nitepone/Waybar?ref=dev/niri-taskbar";
    # catppuccin.url    = "github:catppuccin/nix/release-25.05";
    niri-flake.url    = "github:sodiboo/niri-flake";
    # refind-mod.url    = "github:GrandtheUK/refind-nix";
    # noctalia = {
    #   url = "github:noctalia-dev/noctalia-shell";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   inputs.noctalia-qs.follows = "noctalia-qs";
    # };

    # noctalia-qs = { 
    #   url = "github:noctalia-dev/noctalia-qs";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    # humble-manager.url = "github:violetbp/humble-manager";
    # humble-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, home-manager, nixpkgs, niri-flake, ... }: 
  # dankMaterialShell , refind-mod, nix-index-database,
  {
    nixosConfigurations = {
      terra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./hostnameConfig/terra-config.nix   
          ./configuration.nix
        ];
      };
      tassadar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hostnameConfig/tassadar-config.nix 
          ./configuration.nix
        ];
      };
      karax = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./hostnameConfig/karax-config.nix  
          ./configuration.nix
          ./windowManager/niri.nix
          ./hardwareConfig/karax-hw.nix
          ./buildClient.nix
          ./desktop.nix
          ./laptop.nix
          ./misc/thunderbolt.nix
          # refind-mod.nixosModules.refind
          # catppuccin.nixosModules.catppuccin
          niri-flake.nixosModules.niri
          inputs.nix-index-database.nixosModules.nix-index

        

          # ({ pkgs, ... }: {
          #   nixpkgs.overlays = [ claude-desktop.overlays.default ];
          #   environment.systemPackages = [ pkgs.claude-desktop ];
          # })
          # ({ ... }: {
          #   environment.systemPackages = [ inputs.claude-desktop.packages.x86_64-linux.claude-desktop ];
          # })
          home-manager.nixosModules.home-manager            
        ];
        specialArgs = { inherit inputs; };
      
      };
	    blade = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./hostnameConfig/blade-config.nix 
          ./configuration.nix
          ./windowManager/niri.nix
          ./nvidia.nix
          ./buildClient.nix
          # refind-mod.nixosModules.refind
          # catppuccin.nixosModules.catppuccin
          inputs.disko.nixosModules.disko
          niri-flake.nixosModules.niri
          inputs.nix-index-database.nixosModules.nix-index
          
          home-manager.nixosModules.home-manager 
        ];
        specialArgs = { inherit inputs; };

      };      
      kerrigan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          ./hostnameConfig/kerrigan-config.nix
          ./configuration.nix
          ./htpc.nix
          ./buildServer.nix
          ./harmonia.nix
          # ./windowManager/niri.nix/
          ./nvidia.nix
          inputs.nix-index-database.nixosModules.nix-index
        ];
      };
      talandar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.nix-index-database.nixosModules.nix-index
          # catppuccin.nixosModules.catppuccin
          inputs.disko.nixosModules.disko
          niri-flake.nixosModules.niri
          inputs.nix-index-database.nixosModules.nix-index
          
          home-manager.nixosModules.home-manager 
          ./hostnameConfig/talandar-config.nix
          ./configuration.nix
          ./laptop.nix
          ./desktop.nix
        ];
        
      };
      htpc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.nix-index-database.nixosModules.nix-index
          ./hostnameConfig/htpc-config.nix
          ./configuration.nix
        ];
      };
    };
  };
}
