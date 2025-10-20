{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-felixkratz = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    homebrew-norwoodj = {
      url = "github:norwoodj/homebrew-tap";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, nixos-generators, home-manager, darwin, homebrew-services, homebrew-felixkratz, homebrew-norwoodj, homebrew-core, homebrew-cask, homebrew-bundle, ... }@inputs:
    let 
      homebrew-services-patched = nixpkgs.legacyPackages.aarch64-darwin.applyPatches {
        name = "homebrew-services-patched";
        src = homebrew-services;
        patches = [./modules/darwin/homebrew-services.patch];
      };
    in
    {
      nixosConfigurations.kasti = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; inherit self;};
        system = "x86_64-linux";
        modules = [ 
          ./hosts/kasti/configuration.nix 
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; inherit self;};
        system = "x86_64-linux";
        modules = [ 
          ./hosts/workstation/configuration.nix 
          inputs.home-manager.nixosModules.default
          (nixos-generators.nixosModules.all-formats)
        ];
      };
      nixosConfigurations.nixos-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; inherit self;};
        system = "x86_64-linux";
        modules = [ 
          ./hosts/nixos-desktop/configuration.nix 
          inputs.home-manager.nixosModules.default
        ];
      };
      nixosConfigurations.framework12 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; inherit self;};
        system = "x86_64-linux";
        modules = [ 
          ./hosts/framework12/configuration.nix 
          inputs.home-manager.nixosModules.default
        ];
      };
      homeConfigurations."josh@silver" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./homes/joshlee.nix
        ];
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      };
      homeConfigurations."josh@pop-os" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./homes/josh.nix
        ];
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
      homeConfigurations."josh@framework12" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./homes/josh-framework12.nix
        ];
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
      darwinConfigurations."sting" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "josh";
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-services" = homebrew-services-patched;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "felixkratz/homebrew-formulae" = homebrew-felixkratz;
                  "norwoodj/tap" = homebrew-norwoodj;
                };
                mutableTaps = true;
                autoMigrate = false;
              };
            }
          ./hosts/macbook/configuration.nix
        ];
      };
    };
}
