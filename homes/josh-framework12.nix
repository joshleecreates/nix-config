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
    ../modules/home-manager/wob.nix
  ];

  modules.framework.enable = true;
  modules.moonlight.enable = true;
  modules.niri.enable = true;
  modules.waybar.enable = true;
  modules.randomWallpaper.enable = true;

  home.packages = with pkgs; [
    discord
  ];

  # Override Steam desktop entry to include Niri timing workaround
  xdg.desktopEntries.steam = {
    name = "Steam";
    comment = "Application for managing and playing games on Steam";
    exec = ''sh -c "sleep 1 && steam %U"'';
    icon = "steam";
    terminal = false;
    type = "Application";
    categories = [ "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };
}
