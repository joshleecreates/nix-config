{ config, pkgs, lib, ... }:

{
  home.username = "joshlee";
  home.homeDirectory = lib.mkForce "/Users/joshlee";
  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports = [
    ./common/shell.nix
    ./common/ops.nix
    ../modules/home-manager/aerospace.nix
    ../modules/home-manager/sketchybar.nix
    ../modules/home-manager/ghostty.nix
  ];

  programs.zsh.oh-my-zsh.theme = lib.mkForce "robbyrussell";

  home.packages = [
    pkgs.pet
    pkgs.yazi
  ];

  programs.zsh = {
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
