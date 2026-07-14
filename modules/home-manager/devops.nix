{ config, lib, pkgs, ... }:

let
  cfg = config.modules.devops;
in
{
  options.modules.devops = {
    enable = lib.mkEnableOption "DevOps tools and configuration";
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
    };
    # Kubernetes context in the prompt is handled by the starship module
    # (KUBE_PROMPT-gated segment + toggle-kube-prompt). See modules/home-manager/starship.nix.
  };
}
