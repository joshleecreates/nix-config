{ lib, ... }:

# Standalone home-manager config for joshlee@silver (macOS laptop)

{
  imports = [
    ../home/macos.nix
  ];

  home.username = "joshlee";
  home.homeDirectory = "/Users/joshlee";
  home.stateVersion = "24.05";
}
