{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.ghostty;
in {
  options.modules.ghostty = {
    enable = mkEnableOption "Ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];

    xdg.configFile.ghostty = {
      target = "ghostty/config";
      source = ./ghostty/config;
    };
  };
}
