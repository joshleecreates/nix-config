{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "work";
  home.homeDirectory = lib.mkForce "/Users/work";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    ./home.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.aerospace
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    T_REPOS_DIR = "$HOME/repos";
  };
}
