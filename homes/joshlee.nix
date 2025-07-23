{ config, pkgs, lib, ... }:

{
  home.username = "joshlee";
  home.homeDirectory = lib.mkForce "/Users/joshlee";
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
  programs.zsh.oh-my-zsh.theme = lib.mkForce "robbyrussell";

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = [
    pkgs.pet
    pkgs.yazi
  ];
}
