{ config, pkgs, lib, ... }:

{
  systemd.user.services.waybar = {
    Unit = {
      After = lib.mkForce "graphical-session.target";
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
    settings = lib.importJSON ./waybar-config.json;

    # Use external style file with Nord theme
    style = builtins.readFile ./waybar-style.css;
  };
}
