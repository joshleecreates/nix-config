{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.pkb-daily;
in {
  options.modules.pkb-daily = {
    enable = mkEnableOption "PKB daily note in Neovim (Ghostty) launcher";
  };

  config = mkIf cfg.enable {
    # Install the script
    home.file.".local/bin/pkb-daily" = {
      source = ./scripts/pkb-daily.sh;
      executable = true;
    };

    # Create desktop entry for the launcher (noctalia, etc.)
    xdg.desktopEntries.pkb-daily = {
      name = "PKB Daily Note";
      comment = "Open today's PKB daily note in Neovim";
      exec = "${config.home.homeDirectory}/.local/bin/pkb-daily";
      icon = "nvim";
      terminal = false;
      type = "Application";
      categories = [ "Office" "Utility" ];
    };
  };
}
