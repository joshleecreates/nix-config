{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.randomWallpaper;
in {
  options.modules.randomWallpaper = {
    enable = mkEnableOption "Random wallpaper service for swww";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Image manipulation for wallpaper blurring
      imagemagick
    ];

    # Random wallpaper script
    home.file.".local/bin/random-wallpaper.sh" = {
      source = ./random-wallpaper.sh;
      executable = true;
    };

    # Random wallpaper service
    systemd.user.services.random-wallpaper = {
      Unit = {
        Description = "Random wallpaper with swww";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash %h/.local/bin/random-wallpaper.sh";
      };
    };
  };
}
