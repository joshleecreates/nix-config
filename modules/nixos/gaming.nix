{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.gaming = {
    enable = mkEnableOption "gaming support (Steam, etc.)";
  };

  config = mkIf config.modules.gaming.enable {
    # Enable Steam
    programs.steam.enable = true;
  };
}
