{ config, pkgs, lib, ... }:

{
  home.username = "joshlee";
  home.homeDirectory = lib.mkForce "/Users/joshlee";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports = [
    ./home.nix
  ];

  home.packages = [
    pkgs.pet
    pkgs.yazi
    pkgs.sesh
  ];
}
