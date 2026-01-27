{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.gaming = {
    enable = mkEnableOption "gaming support (Steam, etc.)";

    steam = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam";
      };
    };
  };

  config = mkIf config.modules.gaming.enable {
    # Ensure graphics module is enabled
    modules.graphics.enable = true;
    modules.graphics.enable32Bit = true;

    # Steam (uses XWayland automatically via niri)
    programs.steam = mkIf config.modules.gaming.steam.enable {
      enable = true;
    };

    # Gamescope for game scaling/FSR
    programs.gamescope = {
      enable = true;
      capSysNice = true;  # Allow nice priority
    };

    # Gamemode for performance optimization
    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
}
