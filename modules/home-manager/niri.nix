{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.niri;
in {
  options.modules.niri = {
    enable = mkEnableOption "Niri Wayland compositor";
  };

  config = mkIf cfg.enable {
    # Cursor theme configuration
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # Wayland packages
    home.packages = with pkgs; [
      xwayland-satellite  # XWayland support for Niri
      # wlr-randr - replaced by kanshi for automatic display profile switching
      pavucontrol  # Audio control
      networkmanagerapplet  # Network manager applet
      blueman  # Bluetooth manager
      rofimoji  # Emoji picker
      wvkbd  # Virtual keyboard for touchscreen mode
      polkit_gnome  # Polkit authentication agent
    ];

    # Niri configuration file
    xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;

    # Niri Wayland services
    services.swayidle.enable = true;


    # Disk automounting
    services.udiskie = {
      enable = true;
      automount = true;
    };

    # XWayland support: niri 25.11+ automatically spawns xwayland-satellite
    # and exports DISPLAY. The package is kept in PATH above.

    # Polkit agent for authentication dialogs (required for elevated permissions)
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Niri-specific environment variables
    home.sessionVariables = {
      # Wayland session
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "niri";

      # Enable Wayland support for Electron/Chromium apps
      NIXOS_OZONE_WL = "1";

      # Force apps to prefer Wayland when available
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # Mozilla/Firefox Wayland
      MOZ_ENABLE_WAYLAND = "1";

      # DISPLAY is set automatically by niri when it spawns xwayland-satellite
    };
  };
}
