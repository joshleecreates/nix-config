{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.zsh;
in {
  options.modules.zsh = {
    prompt = mkOption {
      type = types.enum [ "oh-my-zsh" "starship" ];
      default = "oh-my-zsh";
      description = "Which prompt to use: oh-my-zsh theme or starship";
    };

    oh-my-zsh = {
      theme = mkOption {
        type = types.str;
        default = "bira";
        description = "Oh-my-zsh theme to use";
      };

      plugins = mkOption {
        type = types.listOf types.str;
        default = [ "aws" "git" "kubectl" "vi-mode" "docker" ];
        description = "Oh-my-zsh plugins to enable";
      };
    };
  };

  config = {
    programs.zsh.oh-my-zsh = mkIf (cfg.prompt == "oh-my-zsh") {
      enable = true;
      theme = cfg.oh-my-zsh.theme;
      plugins = cfg.oh-my-zsh.plugins;
    };

    programs.starship = mkIf (cfg.prompt == "starship") {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
