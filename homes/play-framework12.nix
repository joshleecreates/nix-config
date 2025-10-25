{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "play";
  home.homeDirectory = lib.mkDefault "/home/play";
  home.stateVersion = lib.mkDefault "25.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./common/desktop.nix
    ../modules/home-manager/alacritty.nix
  ];

  home.packages = with pkgs; [
  ];

  # Font configuration
  fonts.fontconfig.enable = true;
}
