{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.zoom;
in {
  options.modules.zoom = {
    enable = mkEnableOption "Zoom video conferencing";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.zoom-us ];

    # Zoom wrapper for Wayland compatibility
    home.file.".local/bin/zoom" = {
      text = ''
        #!/usr/bin/env bash
        export QT_QPA_PLATFORM=xcb
        export DISPLAY=:0
        exec ${pkgs.zoom-us}/bin/zoom-us "$@"
      '';
      executable = true;
    };
  };
}
