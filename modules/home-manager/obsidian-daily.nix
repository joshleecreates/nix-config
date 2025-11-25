{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.obsidian-daily;
in {
  options.modules.obsidian-daily = {
    enable = mkEnableOption "Obsidian daily note launcher";
  };

  config = mkIf cfg.enable {
    # Install the script
    home.file.".local/bin/obsidian-daily" = {
      source = ./scripts/obsidian-daily.sh;
      executable = true;
    };

    # Create desktop entry for launcher
    xdg.desktopEntries.obsidian-daily = {
      name = "Obsidian Daily Note";
      comment = "Open today's daily note in Obsidian";
      exec = "${config.home.homeDirectory}/.local/bin/obsidian-daily";
      icon = "obsidian";
      terminal = false;
      type = "Application";
      categories = [ "Office" "Utility" ];
    };
  };
}
