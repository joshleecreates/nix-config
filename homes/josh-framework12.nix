{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ./common/shell.nix
    ./common/desktop.nix
    ./common/ops.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/framework.nix
    ../modules/home-manager/moonlight.nix
    ../modules/home-manager/obsidian-daily.nix
    ../modules/home-manager/gaming.nix
    ../modules/home-manager/zen-browser.nix

    #niri
    # Replaced by noctalia-shell: mako.nix, waybar.nix, random-wallpaper.nix, wob.nix
    ../modules/home-manager/niri.nix
    ../modules/home-manager/nirius.nix
    ../modules/home-manager/kanshi.nix
    ../modules/home-manager/niri-lid-handler.nix
  ];

  modules.framework.enable = true;
  modules.moonlight.enable = true;
  modules.niri.enable = true;
  modules.nirius.enable = true;
  modules.kanshi.enable = true;
  modules.niri-lid-handler.enable = true;
  modules.obsidian-daily.enable = true;
  modules.gaming.enable = true;
  modules.zen-browser.enable = false;

  # Noctalia shell - replaces waybar, mako, wob, swww/random-wallpaper
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      notifications = {
        normalUrgencyDuration = 60;  # Auto-dismiss after 60 seconds
      };
      audio = {
        mprisBlacklist = [ "spotify" ];  # Don't show Spotify in media widget
      };
    };
  };

  # Configure foot terminal
  programs.foot = {
    enable = true;
    server.enable = true;  # Enable foot server for footclient
    settings = {
      main = {
        font = "monospace:size=14";
      };
      colors = {
        # Match ghostty's 0.85 opacity (217/255 = 0.85)
        # Format: rrggbbaa (alpha: d9 = 217 in hex)
        alpha = "0.85";
      };
    };
  };

  home.packages = with pkgs; [
    discord
    distrobox
    kdePackages.ark
    kdePackages.gwenview
    libheif
    unzip
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Archives (Ark)
      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/gzip" = [ "org.kde.ark.desktop" ];
      "application/x-rar" = [ "org.kde.ark.desktop" ];
      # Web (Firefox)
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
      # Video (VLC)
      "video/mp4" = [ "vlc.desktop" ];
      # App handlers
      "x-scheme-handler/slack" = [ "slack.desktop" ];
      "x-scheme-handler/sgnl" = [ "signal.desktop" ];
      "x-scheme-handler/signalcaptcha" = [ "signal.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;

  # Spotify Player desktop entry
  xdg.desktopEntries.spotify-player = {
    name = "Spotify Player";
    comment = "Terminal Spotify client";
    exec = "foot --app-id=spotify_ui --font=monospace:size=18 spotify_player";
    icon = "spotify";
    terminal = false;
    type = "Application";
    categories = [ "Audio" "Music" "Player" ];
  };

  # btop desktop entry
  xdg.desktopEntries.btop = {
    name = "btop";
    comment = "Resource monitor";
    exec = "foot --app-id=btop_ui --font=monospace:size=13 btop";
    icon = "utilities-system-monitor";
    terminal = false;
    type = "Application";
    categories = [ "System" "Monitor" ];
  };

  # Fuzzel launcher - Nord theme styling
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
        # Nord theme colors with transparency
        background = "2e3440ee";        # Nord polar night (semi-transparent)
        text = "d8dee9ff";              # Nord snow storm
        match = "88c0d0ff";             # Nord frost (accent color matching window borders)
        selection = "4c566aff";         # Nord polar night (darker)
        selection-text = "eceff4ff";    # Nord snow storm (bright)
        selection-match = "88c0d0ff";   # Nord frost
        border = "88c0d0ff";            # Nord frost (matching window active border)
      };
      border = {
        width = 3;                      # Match niri window border width
        radius = 8;                     # Match niri window corner radius
      };
    };
  };

  # ChatGPT web app
  xdg.desktopEntries.chatgpt = {
    name = "ChatGPT";
    comment = "ChatGPT web application";
    exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=chatgpt --name=chatgpt --app-id=chatgpt --user-data-dir=${config.home.homeDirectory}/.local/share/chatgpt-ssb --app=https://chatgpt.com";
    icon = "chromium";
    terminal = false;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };

  # Google Meet web app
  xdg.desktopEntries.google-meet = {
    name = "Google Meet";
    comment = "Google Meet video conferencing";
    exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=google-meet --name=google-meet --app-id=google-meet --user-data-dir=${config.home.homeDirectory}/.local/share/google-meet-ssb --app=https://meet.google.com";
    icon = "chromium";
    terminal = false;
    type = "Application";
    categories = [ "Network" "VideoConference" ];
  };
}
