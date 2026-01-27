{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.wayland = {
    enable = mkEnableOption "Wayland desktop environment support";

    screenShare = mkOption {
      type = types.bool;
      default = true;
      description = "Enable screen sharing via XDG portal (wlr backend)";
    };

    compositor = mkOption {
      type = types.enum [ "niri" "sway" "other" ];
      default = "niri";
      description = "Which Wayland compositor to configure portals for";
    };
  };

  config = mkIf config.modules.wayland.enable {
    # PipeWire audio (required for screen sharing and modern audio)
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk  # File pickers, app choosers
      ] ++ (optionals config.modules.wayland.screenShare [
        pkgs.xdg-desktop-portal-wlr  # Screen sharing for wlroots compositors
      ]);
      config = mkMerge [
        {
          common = {
            default = [ "gtk" ];
          };
        }
        (mkIf (config.modules.wayland.compositor == "niri") {
          niri = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          };
        })
        (mkIf (config.modules.wayland.compositor == "sway") {
          sway = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          };
        })
      ];
    };

    # PAM configuration for swaylock
    security.pam.services.swaylock = {};

    # Essential Wayland packages
    environment.systemPackages = with pkgs; [
      wl-clipboard  # Clipboard utilities
    ];
  };
}
