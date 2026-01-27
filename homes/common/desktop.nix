{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/firefox.nix
    ../../modules/home-manager/vivaldi.nix
    ../../modules/home-manager/thunderbird.nix
    ../../modules/home-manager/zoom.nix
    ../../modules/home-manager/prusa.nix
  ];

  # Enable modules
  modules.ghostty.enable = true;
  modules.firefox.enable = true;
  modules.firefox.onePasswordIntegration = true;
  modules.vivaldi.enable = true;
  modules.vivaldi.onePasswordIntegration = true;
  modules.thunderbird.enable = true;
  modules.thunderbird.onePasswordIntegration = true;
  modules.zoom.enable = true;
  modules.prusa.enable = true;

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

  # Hardware acceleration env vars are set system-wide in host configs
  # (e.g., LIBVA_DRIVER_NAME for Intel in framework12)

  # Override Termius desktop file to add URL scheme handler for OAuth redirects
  xdg.desktopEntries.termius-app = {
    name = "Termius";
    genericName = "Cross-platform SSH client";
    comment = "The SSH client that works on Desktop and Mobile";
    exec = "termius-app %u";
    icon = "termius-app";
    categories = [ "Network" ];
    mimeType = [ "x-scheme-handler/termius" ];
  };
}
