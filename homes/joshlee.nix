{ config, pkgs, lib, ... }:

{
  home.username = "joshlee";
  home.homeDirectory = "/Users/joshlee";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports = [
    ./home.nix
    ../modules/home-manager/aerospace.nix
    ../modules/home-manager/sketchybar.nix
    ../modules/home-manager/ghostty.nix
    ../modules/home-manager/k8s-prompt.nix
  ];

  modules.k8s-prompt.enable = true;
  modules.sesh.enable = true;
  
  home.packages = [
    pkgs.pet
    pkgs.yazi
  ];
}
