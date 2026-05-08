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
    programs.zsh.initContent = ''
      eval "$(zoxide init zsh)"

      function s() {
        local session
        session=$(sesh list | fzf) || return
        if [ -n "$TMUX" ]; then
          sesh connect "$session"
        else
          tmux attach-session -t "$session" 2>/dev/null || sesh connect "$session"
        fi
      }
    '';
  };
}
