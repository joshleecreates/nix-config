{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar-niri-workspaces-enhanced = {
      url = "github:justbuchanan/waybar-niri-workspaces-enhanced";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.framework12 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs; inherit self;};
        system = "x86_64-linux";
        modules = [
          ./hosts/framework12/configuration.nix
          inputs.home-manager.nixosModules.default
          inputs.noctalia.nixosModules.default
          {
            # Enable noctalia-shell systemd service
            services.noctalia-shell.enable = true;
          }
          {
            home-manager.sharedModules = [
              inputs.waybar-niri-workspaces-enhanced.homeModules.default
              inputs.noctalia.homeModules.default
            ];
            home-manager.extraSpecialArgs = {
              zen-browser-pkg = inputs.zen-browser.packages."x86_64-linux".zen-browser-unwrapped;
            };
          }
        ];
      };
      # Standalone home-manager configurations
      homeConfigurations."josh@draper" = home-manager.lib.homeManagerConfiguration {
        modules = [ ./homes/josh-draper.nix ];
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      homeConfigurations."josh@framework12" = home-manager.lib.homeManagerConfiguration {
        modules = [ ./hosts/framework12/josh.nix ];
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      homeConfigurations."joshlee@silver" = home-manager.lib.homeManagerConfiguration {
        modules = [ ./homes/joshlee-silver.nix ];
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      };
    };
}
