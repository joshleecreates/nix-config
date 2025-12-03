{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/ghostty.nix
    ../../modules/home-manager/firefox.nix
    ../../modules/home-manager/vivaldi.nix
    ../../modules/home-manager/thunderbird.nix
    ../../modules/home-manager/zoom.nix
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

    # Hardware acceleration libraries for Intel graphics
    intel-media-driver  # VAAPI driver for Intel Gen 8+ (Broadwell and newer)
    libva               # Video Acceleration API
    libva-utils         # Utilities for VA-API (includes vainfo)
    ocl-icd             # OpenCL ICD loader (for DaVinci Resolve, Blender)
    clinfo              # OpenCL info utility (check OpenCL support)
  ];

  # Global environment variables for hardware video acceleration
  home.sessionVariables = {
    # Enable VA-API for hardware video decoding (DaVinci, browsers, media players)
    LIBVA_DRIVER_NAME = "iHD";  # Intel iHD driver (modern, for Gen 8+)

    # Vulkan ICD for Intel
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";

    # OpenCL ICD for Intel (DaVinci Resolve, Blender, etc.)
    OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
  };

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
