{ config, pkgs, lib, ... }:

# macOS configuration - standalone home-manager (no nix-darwin)
# Imports home.nix for base CLI tools

{
  imports = [
    ./home.nix

    # macOS GUI
    ../modules/home-manager/aerospace.nix
    ../modules/home-manager/sketchybar.nix
    ../modules/home-manager/ghostty.nix
  ];

  # Enable macOS modules
  modules.aerospace.enable = true;
  modules.sketchybar.enable = true;
  modules.ghostty.enable = true;

  # Override zsh theme for macOS
  programs.zsh.oh-my-zsh.theme = lib.mkForce "robbyrussell";

  home.packages = with pkgs; [
    pet
    yazi
  ];
}
