{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  options.modules.devops = {
    enable = lib.mkEnableOption "DevOps tools and configuration";

    k8sPrompt = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Kubernetes context in ZSH prompt";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
      kubectl
      kubectx
      kubernetes-helm
      opentofu
      ansible
      talosctl
      argocd
      minikube
      cilium-cli
    ];

    # k9s configuration
    programs.k9s = {
      enable = true;
      settings.k9s = {
        ui = {
          headless = true;
          logoless = true;
          noIcons = true;
        };
        skipLatestRevCheck = true;
      };
    };

    programs.zsh.shellAliases = {
      ks = "XDG_CONFIG_HOME=~/.config XDG_DATA_HOME=~/.config k9s";
    } // lib.optionalAttrs cfg.k8sPrompt {
      toggle-k8s-prompt = "toggle-k8s-prompt";
    };

    # Kubernetes context in prompt
    programs.zsh.initContent = lib.mkIf cfg.k8sPrompt ''
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
  };
}
