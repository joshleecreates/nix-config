{ config, pkgs, lib, ... }:

# Linux desktop configuration - GUI apps + Wayland/Niri
# Imports home.nix for base CLI tools

{
  imports = [
    ./home.nix

    # GUI applications
    ../modules/home-manager/ghostty.nix
    ../modules/home-manager/firefox.nix
    ../modules/home-manager/vivaldi.nix
    ../modules/home-manager/thunderbird.nix
    ../modules/home-manager/zoom.nix
    ../modules/home-manager/prusa.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/obsidian-daily.nix
    ../modules/home-manager/gaming.nix
    ../modules/home-manager/zen-browser.nix

    # Wayland / Niri
    ../modules/home-manager/niri.nix
    ../modules/home-manager/nirius.nix
    ../modules/home-manager/niri-lid-handler.nix
  ];

  # Enable GUI modules
  modules.ghostty.enable = true;
  modules.firefox.enable = true;
  modules.firefox.onePasswordIntegration = true;
  modules.vivaldi.enable = true;
  modules.vivaldi.onePasswordIntegration = true;
  modules.thunderbird.enable = true;
  modules.thunderbird.onePasswordIntegration = true;
  modules.zoom.enable = true;
  modules.prusa.enable = true;
  modules.alacritty.enable = true;

  # Enable Wayland / Niri
  modules.niri.enable = true;
  modules.nirius.enable = true;
  modules.niri-lid-handler.enable = true;

  # Optional desktop features (enabled by default, can override)
  modules.obsidian-daily.enable = lib.mkDefault true;
  modules.gaming.enable = lib.mkDefault false;
  modules.zen-browser.enable = lib.mkDefault false;

  # Noctalia shell - status bar, notifications, wallpaper
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      notifications = {
        normalUrgencyDuration = 60;
      };
      audio = {
        mprisBlacklist = [ "spotify" ];
      };
    };
  };

  # Foot terminal
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
      };
      colors = {
        alpha = "0.85";
      };
    };
  };

  # Fuzzel launcher - Nord theme
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=14";
        terminal = "foot";
        layer = "overlay";
        prompt = "❯ ";
      };
      colors = {
        background = "2e3440ee";
        text = "d8dee9ff";
        match = "88c0d0ff";
        selection = "4c566aff";
        selection-text = "eceff4ff";
        selection-match = "88c0d0ff";
        border = "88c0d0ff";
      };
      border = {
        width = 3;
        radius = 8;
      };
    };
  };

  home.packages = with pkgs; [
    # Desktop tools
    chromium
    slack
    termius
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
    _1password-gui
    discord
    distrobox
    libheif
    unzip

    # Media
    mpv
    spotify
    spotify-player
    vlc
    davinci-resolve
    signal-desktop-bin
    ffmpeg-full
  ];

  # MIME type associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Archives
      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/gzip" = [ "org.kde.ark.desktop" ];
      "application/x-rar" = [ "org.kde.ark.desktop" ];
      # Web
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      # Video
      "video/mp4" = [ "vlc.desktop" ];
      # App handlers
      "x-scheme-handler/slack" = [ "slack.desktop" ];
      "x-scheme-handler/sgnl" = [ "signal.desktop" ];
      "x-scheme-handler/signalcaptcha" = [ "signal.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;

  # Desktop entries
  xdg.desktopEntries = {
    termius-app = {
      name = "Termius";
      genericName = "Cross-platform SSH client";
      comment = "The SSH client that works on Desktop and Mobile";
      exec = "termius-app %u";
      icon = "termius-app";
      categories = [ "Network" ];
      mimeType = [ "x-scheme-handler/termius" ];
    };

    spotify-player = {
      name = "Spotify Player";
      comment = "Terminal Spotify client";
      exec = "foot --app-id=spotify_ui --font=monospace:size=18 spotify_player";
      icon = "spotify";
      terminal = false;
      type = "Application";
      categories = [ "Audio" "Music" "Player" ];
    };

    btop = {
      name = "btop";
      comment = "Resource monitor";
      exec = "foot --app-id=btop_ui --font=monospace:size=13 btop";
      icon = "utilities-system-monitor";
      terminal = false;
      type = "Application";
      categories = [ "System" "Monitor" ];
    };

    chatgpt = {
      name = "ChatGPT";
      comment = "ChatGPT web application";
      exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=chatgpt --name=chatgpt --app-id=chatgpt --user-data-dir=${config.home.homeDirectory}/.local/share/chatgpt-ssb --app=https://chatgpt.com";
      icon = "chromium";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
    };

    google-meet = {
      name = "Google Meet";
      comment = "Google Meet video conferencing";
      exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=google-meet --name=google-meet --app-id=google-meet --user-data-dir=${config.home.homeDirectory}/.local/share/google-meet-ssb --app=https://meet.google.com";
      icon = "chromium";
      terminal = false;
      type = "Application";
      categories = [ "Network" "VideoConference" ];
    };
  };
}
