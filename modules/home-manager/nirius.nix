{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.nirius;
in {
  options.modules.nirius = {
    enable = mkEnableOption "Nirius scratchpad utility for niri";

    scratchpads = mkOption {
      type = types.listOf (types.submodule {
        options = {
          appId = mkOption {
            type = types.str;
            description = "The app-id to match for this scratchpad";
          };
          spawn = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Command to spawn if the app isn't running";
          };
        };
      });
      default = [];
      description = "List of scratchpad configurations";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nirius ];

    # Start niriusd daemon via systemd user service
    systemd.user.services.niriusd = {
      Unit = {
        Description = "Nirius daemon for niri scratchpad functionality";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.nirius}/bin/niriusd";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}
