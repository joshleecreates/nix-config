{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.k8s-prompt;
in {
  options.modules.k8s-prompt = {
    enable = mkEnableOption "Kubernetes context in ZSH prompt";
  };

  config = mkIf cfg.enable {
    programs.zsh.initExtra = ''
      # Kubernetes context in prompt
      function kube_prompt_info() {
        if command -v kubectx >/dev/null; then
          local k8s_ctx=$(kubectx -c 2>/dev/null)
          
          if [[ -n "$k8s_ctx" ]]; then
            echo "%F{cyan}[$k8s_ctx]%f "
          fi
        fi
      }

      # Add to PROMPT
      setopt PROMPT_SUBST
      PROMPT='$(kube_prompt_info)'"$PROMPT"
    '';
  };
}