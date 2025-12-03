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
      pkgs.libnotify  # For notify-send (calendar notifications)
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

    # Calendar notification service
    systemd.user.services.calendar-notify = {
      Unit = {
        Description = "Calendar event notification checker";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3}/bin/python3 ${config.home.homeDirectory}/.config/waybar/custom_modules/calendar-notify.py";
      };
    };

    # Timer to run calendar notifications every minute
    systemd.user.timers.calendar-notify = {
      Unit = {
        Description = "Check for upcoming calendar events";
      };
      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = "1min";
        Unit = "calendar-notify.service";
      };
      Install = {
        WantedBy = [ "timers.target" ];
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

    xdg.configFile."waybar/custom_modules/thunderbird-calendar.py" = {
      source = ./waybar-scripts/thunderbird-calendar.py;
      executable = true;
    };

    xdg.configFile."waybar/custom_modules/calendar-notify.py" = {
      source = ./waybar-scripts/calendar-notify.py;
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
