{ config, pkgs, lib, ... }:

{
  services.mako = {
    enable = true;

    settings = {
      # Appearance
      font = "JetBrains Mono Nerd Font 11";
      width = 400;
      height = 150;
      margin = 20;
      padding = 15;
      border-size = 2;
      border-radius = 10;

      # Nord color scheme
      background-color = "#2e3440";
      text-color = "#eceff4";
      border-color = "#88c0d0";
      progress-color = "over #5e81ac";

      # Icons
      icons = true;
      max-icon-size = 48;
      icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";

      # Behavior
      default-timeout = 5000;
      ignore-timeout = false;

      # Grouping
      group-by = "app-name";

      # Sorting (most recent on top)
      sort = "-time";

      # Layer (overlay on top of everything)
      layer = "overlay";

      # Anchor to top right
      anchor = "top-right";

      # Extra config for different urgency levels
      "[urgency=low]" = {
        border-color = "#a3be8c";
        default-timeout = 3000;
      };

      "[urgency=normal]" = {
        border-color = "#88c0d0";
        default-timeout = 5000;
      };

      "[urgency=high]" = {
        border-color = "#bf616a";
        default-timeout = 0;
        background-color = "#3b4252";
        text-color = "#eceff4";
      };

      "[app-name=\"Spotify\"]" = {
        border-color = "#81a1c1";
      };

      "[app-name=\"Volume\"]" = {
        border-color = "#a3be8c";
        default-timeout = 2000;
      };

      "[app-name=\"Brightness\"]" = {
        border-color = "#ebcb8b";
        default-timeout = 2000;
      };
    };
  };

  # Add Papirus icon theme for nice notification icons
  home.packages = with pkgs; [
    papirus-icon-theme
  ];
}
