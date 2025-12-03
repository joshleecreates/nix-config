{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.gaming = {
    enable = mkEnableOption "gaming support (Steam, etc.)";
  };

  config = mkIf config.modules.gaming.enable {
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
    ];
  };
}
