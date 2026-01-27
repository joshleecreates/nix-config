{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.graphics = {
    enable = mkEnableOption "graphics acceleration support";

    enable32Bit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 32-bit graphics support (for Steam, Wine, etc.)";
    };
  };

  config = mkIf config.modules.graphics.enable {
    # Base graphics support
    hardware.graphics = {
      enable = true;
      enable32Bit = config.modules.graphics.enable32Bit;
      extraPackages = with pkgs; [
        mesa  # Mesa drivers including Vulkan
      ];
    };

    # Vulkan support (hardware-agnostic)
    environment.systemPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
      libva-utils  # VA-API diagnostics
    ];
  };
}
