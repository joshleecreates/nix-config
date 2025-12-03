{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.k8s-prompt;
in {
  options.modules.k8s-prompt = {
    enable = mkEnableOption "Kubernetes context in ZSH prompt";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      initContent = ''
        # Kubernetes context in prompt
        function kube_prompt_info() {
          if command -v kubectx >/dev/null; then
            local k8s_ctx=$(kubectx -c 2>/dev/null)
            
            if [[ -n "$k8s_ctx" ]]; then
              echo "%F{magenta}[$k8s_ctx]%f "
            fi
          fi
        }

        # Add to PROMPT
        setopt PROMPT_SUBST
        K8S_PROMPT='$(kube_prompt_info)'"$PROMPT"
        OG_PROMPT="$PROMPT"
        PROMPT="$K8S_PROMPT"

        # Function to toggle k8s prompt
        function toggle-k8s-prompt() {
          if [[ "$PROMPT" == "$K8S_PROMPT" ]]; then
            PROMPT="$OG_PROMPT"
            echo "Kubernetes prompt disabled"
          else
            PROMPT="$K8S_PROMPT"
            echo "Kubernetes prompt enabled"
          fi
        }
      '';
      
      shellAliases = {
        toggle-k8s-prompt = "toggle-k8s-prompt";
      };
    };
  };
}
