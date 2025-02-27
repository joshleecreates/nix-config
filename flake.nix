{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
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
  };

  outputs = { self, nixpkgs, home-manager, darwin, homebrew-services, homebrew-felixkratz, homebrew-norwoodj, homebrew-core, homebrew-cask, homebrew-bundle, ... }@inputs:
    let 
      homebrew-services-patched = nixpkgs.legacyPackages.aarch64-darwin.applyPatches {
        name = "homebrew-services-patched";
        src = homebrew-services;
        patches = [./modules/darwin/homebrew-services.patch];
      };
      homebrewTaps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
        "homebrew/homebrew-services" = homebrew-services-patched;
        "homebrew/homebrew-bundle" = homebrew-bundle;
        "felixkratz/homebrew-formulae" = homebrew-felixkratz;
        "norwoodj/tap" = homebrew-norwoodj;
      };
    in
    {
      nixosConfigurations.kasti = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [ 
          ./hosts/kasti/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      homeConfigurations."joshlee" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./homes/joshlee.nix
        ];
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      };
      homeConfigurations."josh" = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./homes/josh.nix
        ];
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
      darwinConfigurations."silver" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "joshlee";
                enable = true;
                taps = homebrewTaps;
                mutableTaps = true;
                autoMigrate = false;
              };
            }
          ./hosts/silver.nix
        ];
      };
      darwinConfigurations."mini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "joshlee";
                enable = true;
                taps = homebrewTaps;
                mutableTaps = true;
                autoMigrate = false;
              };
            }
          ./hosts/mini.nix
        ];
      };
    };
}
