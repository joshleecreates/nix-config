{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.btop;

  themes = {
    rose-pine = {
      theme_background = "False";
      color_theme = "rose-pine";
    };
    nord = {
      theme_background = "False";
      color_theme = "nord";
    };
  };
in {
  options.modules.btop = {
    enable = mkEnableOption "btop system monitor";

    theme = mkOption {
      type = types.enum [ "rose-pine" "nord" ];
      default = "rose-pine";
      description = "Color theme for btop";
    };
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = themes.${cfg.theme}.color_theme;
        theme_background = themes.${cfg.theme}.theme_background;
        vim_keys = true;
      };
    };
  };
}
