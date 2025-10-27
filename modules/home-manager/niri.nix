{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.niri;
in {
  options.modules.niri = {
    enable = mkEnableOption "Niri Wayland compositor";
  };

  config = mkIf cfg.enable {
    # Wayland packages
    home.packages = with pkgs; [
      xwayland-satellite  # XWayland support for Niri
      xdg-desktop-portal-gnome  # Desktop portal
      wlr-randr  # Wayland display configuration
      pavucontrol  # Audio control
      networkmanagerapplet  # Network manager applet
      blueman  # Bluetooth manager
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
      # Set DISPLAY for X11 compatibility (some tools still check this)
      DISPLAY = ":0";
    };
  };
}
