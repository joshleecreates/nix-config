{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.waybar;
in {
  options.modules.waybar = {
    enable = mkEnableOption "Waybar status bar for Wayland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ 
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.symbols-only
      pkgs.python3
    ];
    systemd.user.services.waybar = {
      Unit = {
        After = mkForce "graphical-session.target";
      };
      Service = {
        ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.procps}/bin/pkill waybar || true'";
        Restart = "on-failure";
      };
    };

    # Copy custom scripts to ~/.config/waybar/custom_modules/
    xdg.configFile."waybar/custom_modules/cpugovernor.sh" = {
      source = ./waybar-scripts/cpugovernor.sh;
      executable = true;
    };

    xdg.configFile."waybar/custom_modules/custom-gpu.sh" = {
      source = ./waybar-scripts/custom-gpu.sh;
      executable = true;
    };

    xdg.configFile."waybar/mediaplayer.py" = {
      source = ./waybar-scripts/mediaplayer.py;
      executable = true;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "graphical-session.target";

      # Use external config file with Nord theme
      settings = importJSON ./waybar-config.json;

      # Use external style file with Nord theme
      style = builtins.readFile ./waybar-style.css;
    };
  };
}
