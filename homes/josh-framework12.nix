{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./common/shell.nix
    ./common/desktop.nix
    ./common/ops.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/framework.nix
    ../modules/home-manager/moonlight.nix

    #niri
    ../modules/home-manager/mako.nix
    ../modules/home-manager/niri.nix
    ../modules/home-manager/waybar.nix
    ../modules/home-manager/random-wallpaper.nix
  ];

  modules.framework.enable = true;
  modules.moonlight.enable = true;
  modules.niri.enable = true;
  modules.waybar.enable = true;
  modules.randomWallpaper.enable = true;

  home.packages = with pkgs; [
  ];
}
