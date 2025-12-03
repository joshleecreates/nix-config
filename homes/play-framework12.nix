{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "play";
  home.homeDirectory = lib.mkDefault "/home/play";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ./common/desktop.nix
    ../modules/home-manager/alacritty.nix
  ];

  # Disable Vivaldi for play user
  modules.vivaldi.enable = lib.mkForce false;

  home.packages = with pkgs; [
  ];

  # Font configuration
  fonts.fontconfig.enable = true;
}
