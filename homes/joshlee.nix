{ config, pkgs, lib, ... }:

{
  home.username = "joshlee";
  home.homeDirectory = "/Users/joshlee";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports = [
    ./home.nix
    ../modules/home-manager/aerospace.nix
    ../modules/home-manager/sketchybar.nix
  ];

  home.packages = [
    pkgs.pet
    pkgs.yazi
    pkgs.sesh
  ];
}
