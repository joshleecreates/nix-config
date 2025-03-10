{ config, pkgs, lib, ... }:

{
  home.username = "work";
  home.homeDirectory = lib.mkForce "/Users/work";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    ./home.nix
    ../modules/home-manager/aerospace.nix
  ];

  home.packages = [
    pkgs.aerospace
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    T_REPOS_DIR = "$HOME/repos";
  };
}
