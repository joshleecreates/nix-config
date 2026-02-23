{ lib, ... }:

# Standalone home-manager config for joshlee@silver (macOS laptop)

{
  imports = [
    ../home/macos.nix
  ];

  home.username = "joshlee";
  home.homeDirectory = "/Users/joshlee";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    claude-code
  ];
}
