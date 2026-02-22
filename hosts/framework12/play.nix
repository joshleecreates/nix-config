{ config, pkgs, lib, ... }:

# Play user on Framework 12 - desktop with gaming focus

{
  home.username = lib.mkDefault "play";
  home.homeDirectory = lib.mkDefault "/home/play";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../../home/desktop.nix
    ./displays.nix
  ];

  # Disable some modules for play user
  modules.vivaldi.enable = lib.mkForce false;

  # Font configuration
  fonts.fontconfig.enable = true;
}
