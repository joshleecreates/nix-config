{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.sesh;
in {
  options.modules.sesh = {
    enable = mkEnableOption "Smart session manager for tmux";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.zoxide
      pkgs.fzf
      pkgs.sesh
    ];
    programs.tmux.extraConfig = ''
      set -g detach-on-destroy off
      bind-key x kill-pane
    '';
    programs.zsh.initExtra = ''
      eval "$(zoxide init zsh)"
    '';
    programs.zsh.shellAliases = {
      s = "sesh connect $(sesh list | fzf)";
    };
  };
}

