{ config, pkgs, lib, ... }:

{
  # Wob - Wayland Overlay Bar
  # Used for displaying volume, brightness, and other overlay indicators

  home.packages = with pkgs; [
    wob
  ];

  # Wob configuration with Nord theme
  xdg.configFile."wob/wob.ini".text = ''
    # Nord-themed wob configuration

    # Timeout in milliseconds (how long the bar stays visible)
    timeout = 1000

    # Maximum value (percentage)
    max = 100

    # Bar dimensions
    height = 50
    width = 400
    border = 3

    # Padding around the bar
    margin = 20
    padding = 10

    # Position on screen
    anchor = top right

    # Nord color scheme (ARGB format)
    # Background: Nord Polar Night (darker) - #2E3440
    background_color = FF2E3440

    # Border: Nord Frost (cyan) - #88C0D0
    border_color = FF88C0D0

    # Bar fill: Nord Frost (lighter blue) - #81A1C1
    bar_color = FF81A1C1

    # Overflow color: Nord Aurora (yellow/warning) - #EBCB8B
    overflow_background_color = FFEBCB8B
    overflow_border_color = FFEBCB8B
    overflow_bar_color = FFBF616A
  '';

  # Systemd service to run wob
  systemd.user.services.wob = {
    Unit = {
      Description = "Wayland Overlay Bar";
      Documentation = "man:wob(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/rm -f %t/wob.sock"
        "${pkgs.coreutils}/bin/mkfifo %t/wob.sock"
      ];
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/tail -f %t/wob.sock | ${pkgs.wob}/bin/wob'";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -f %t/wob.sock";
      Restart = "always";
      RestartSec = "1s";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
