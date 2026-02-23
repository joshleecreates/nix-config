{ config, lib, ... }:

with lib;

let
  cfg = config.modules.sketchybar;
in {
  options.modules.sketchybar = {
    enable = mkEnableOption "Sketchybar status bar for macOS";
  };

  config = mkIf cfg.enable {
    xdg.configFile.sketchybar = {
      source = ./sketchybar;
      recursive = true;
      executable = true;
    };
  };
}
