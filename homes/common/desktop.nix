{ config, pkgs, lib, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/firefox.nix
    ../../modules/home-manager/thunderbird.nix
    ../../modules/home-manager/zoom.nix
  ];

  # Enable modules
  modules.ghostty.enable = true;
  modules.firefox.enable = true;
  modules.firefox.onePasswordIntegration = true;
  modules.thunderbird.enable = true;
  modules.thunderbird.onePasswordIntegration = true;
  modules.zoom.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Desktop tools
    chromium
    slack
    termius
    kdePackages.dolphin
    _1password-gui

    # Media
    mpv
    spotify
    spotify-player
    vlc
    davinci-resolve
    signal-desktop-bin

    # Codecs for DaVinci Resolve (fixes thumbnails/video playback)
    ffmpeg-full
  ];
}
