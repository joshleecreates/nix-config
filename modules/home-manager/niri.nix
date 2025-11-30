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
      xdg-desktop-portal-gnome  # Desktop portal
      # wlr-randr - replaced by kanshi for automatic display profile switching
      pavucontrol  # Audio control
      networkmanagerapplet  # Network manager applet
      blueman  # Bluetooth manager
      rofimoji  # Emoji picker
      wvkbd  # Virtual keyboard for touchscreen mode
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

    # XWayland support via xwayland-satellite
    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "XWayland Satellite for Niri";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Polkit agent for authentication dialogs
    # Commented out to test if Plasma's polkit agent is sufficient
    # If you get "Authentication is required" errors without a prompt dialog,
    # uncomment this and switch to lxqt-policykit-agent instead
    # systemd.user.services.polkit-gnome-authentication-agent-1 = {
    #   Unit.Description = "polkit-gnome-authentication-agent-1";
    #   Install.WantedBy = [ "graphical-session.target" ];
    #   Service = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    #     Restart = "on-failure";
    #     RestartSec = 1;
    #     TimeoutStopSec = 10;
    #   };
    # };

    # Niri-specific environment variables
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";  # Enable Wayland support for Electron apps
      # XWayland environment variables
      # xwayland-satellite will set DISPLAY dynamically
      # Force apps to prefer Wayland when available
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };
  };
}
