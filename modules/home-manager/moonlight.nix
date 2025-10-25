{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.moonlight;
in {
  options.modules.moonlight = {
    enable = mkEnableOption "Moonlight game streaming client with hardware acceleration";
  };

  config = mkIf cfg.enable {
    # Install Moonlight Qt client
    home.packages = with pkgs; [
      moonlight-qt

      # Hardware acceleration libraries for Intel
      intel-media-driver  # VAAPI driver for Intel Gen 8+ (Broadwell and newer)
      libva               # Video Acceleration API
      libva-utils         # Utilities for VA-API (includes vainfo)
    ];

    # Environment variables for hardware acceleration
    home.sessionVariables = {
      # Enable VA-API for hardware video decoding
      LIBVA_DRIVER_NAME = "iHD";  # Intel iHD driver (newer, for Gen 8+)

      # Vulkan ICD for Intel
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    };

    # XDG desktop entry customization (optional)
    xdg.desktopEntries.moonlight = {
      name = "Moonlight";
      comment = "Stream games from your NVIDIA GameStream-enabled PC";
      exec = "moonlight-qt";
      icon = "moonlight";
      terminal = false;
      type = "Application";
      categories = [ "Game" "Network" ];
    };

    # Shell alias for checking hardware acceleration support
    programs.zsh.shellAliases = {
      vainfo = "vainfo";  # Check VA-API driver and capabilities
      moonlight-check = "vainfo && echo '\\nHardware acceleration ready for Moonlight'";
    };
  };
}
