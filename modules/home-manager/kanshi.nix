{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.kanshi;
in {
  options.modules.kanshi = {
    enable = mkEnableOption "Kanshi dynamic display configuration";
  };

  config = mkIf cfg.enable {
    # Install kanshi
    home.packages = with pkgs; [ kanshi ];

    # Kanshi service for automatic display profile switching
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";

      settings = [
        # Profile 1: Laptop + External (dual display) - check this first
        {
          profile = {
            name = "laptop-and-external";
            outputs = [
              {
                criteria = "BOE NV122WUM-N42 Unknown";
                status = "enable";
                mode = "1920x1200@60.002";
                scale = 1.25;
                position = "0,0";
              }
              {
                criteria = "Samsung Electric Company SAMSUNG Unknown";
                status = "enable";
                mode = "3840x2160@60.000";
                scale = 1.25;
                position = "1536,0";  # To the right of laptop (1920/1.25 = 1536)
              }
            ];
          };
        }

        # Profile 2: Laptop only (internal display)
        {
          profile = {
            name = "laptop-only";
            outputs = [
              {
                criteria = "BOE NV122WUM-N42 Unknown";
                status = "enable";
                mode = "1920x1200@60.002";
                scale = 1.25;
                position = "0,0";
              }
            ];
          };
        }

        # Profile 3: External only (close lid / clamshell mode)
        {
          profile = {
            name = "external-only";
            outputs = [
              {
                criteria = "BOE NV122WUM-N42 Unknown";
                status = "disable";
              }
              {
                criteria = "Samsung Electric Company SAMSUNG Unknown";
                status = "enable";
                mode = "3840x2160@60.000";
                scale = 1.25;
                position = "0,0";
              }
            ];
          };
        }
      ];
    };
  };
}
