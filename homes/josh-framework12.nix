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
    ../modules/home-manager/obsidian-daily.nix

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
  modules.obsidian-daily.enable = true;

  # Enable waybar niri workspaces enhancement
  programs.waybar.niri-workspaces-enhanced.enable = true;

  # Configure foot terminal
  programs.foot = {
    enable = true;
    server.enable = true;  # Enable foot server for footclient
    settings = {
      main = {
        font = "monospace:size=14";
      };
    };
  };

  home.packages = with pkgs; [
    discord
    distrobox
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
    exec = "foot --app-id=btop_ui --font=monospace:size=18 btop";
    icon = "utilities-system-monitor";
    terminal = false;
    type = "Application";
    categories = [ "System" "Monitor" ];
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
