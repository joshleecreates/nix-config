{ config, lib, ... }:

with lib;

let
  cfg = config.modules.starship;
in
{
  options.modules.starship.enable = mkEnableOption "starship prompt with env-var-gated kube segment";

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        palette = "rose_pine";

        palettes.rose_pine = {
          overlay = "#26233a";
          love = "#eb6f92";
          gold = "#f6c177";
          rose = "#ebbcba";
          pine = "#31748f";
          foam = "#9ccfd8";
          iris = "#c4a7e7";
          text = "#e0def4";
          subtle = "#908caa";
          muted = "#6e6a86";
          base = "#191724";
          surface = "#1f1d2e";
        };

        format = "$directory$git_branch$git_status$kubernetes$aws$character";

        directory = {
          style = "bold iris";
          format = "[$path]($style) ";
          truncation_length = 3;
        };

        git_branch = {
          style = "bold foam";
          format = "[$symbol$branch]($style) ";
        };

        git_status = {
          style = "bold love";
          format = "([$all_status$ahead_behind]($style) )";
        };

        # Gated on the KUBE_PROMPT env var. disabled = false keeps the segment
        # eligible; detect_env_vars is what actually shows/hides it. Starship
        # treats an *empty* value as set, so the toggle must unset, not "".
        kubernetes = {
          disabled = false;
          detect_env_vars = [ "KUBE_PROMPT" ];
          style = "bold pine";
          format = "[$symbol$context( \\($namespace\\))]($style) ";
        };

        aws = {
          style = "bold gold";
          format = "[$symbol($profile )(\\($region\\) )]($style)";
        };

        character = {
          success_symbol = "[❯](bold rose)";
          error_symbol = "[❯](bold love)";
        };
      };
    };

    # Seed KUBE_PROMPT from the persistent state file at shell start, and define
    # the toggle as a zsh function so it flips the current shell immediately and
    # persists for new shells. Merges with the existing initContent (types.lines).
    programs.zsh.initContent = ''
      # Seed the kube prompt from its persistent state (default off).
      if [ "$(cat "''${XDG_STATE_HOME:-$HOME/.local/state}/kube-prompt" 2>/dev/null)" = "on" ]; then
        export KUBE_PROMPT=1
      fi

      toggle-kube-prompt() {
        local state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
        mkdir -p "$state_dir"
        if [ -n "''${KUBE_PROMPT+x}" ]; then
          unset KUBE_PROMPT
          echo off > "$state_dir/kube-prompt"
          echo "Kubernetes context: OFF"
        else
          export KUBE_PROMPT=1
          echo on > "$state_dir/kube-prompt"
          echo "Kubernetes context: ON"
        fi
      }
    '';
  };
}
