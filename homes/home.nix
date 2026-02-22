{ config, pkgs, lib, ... }:

# Base home configuration - CLI tools for all systems
# Import this for servers, headless machines, or as base for desktop/macos

{
  imports = [
    # CLI tools
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/sesh.nix
    # Ops tools
    ../modules/home-manager/k9s.nix
    ../modules/home-manager/k8s-prompt.nix
  ];

  # Enable modules
  modules.sesh.enable = true;
  modules.k8s-prompt.enable = true;

  home.packages = with pkgs; [
    # Standard CLI tools
    pay-respects
    git
    gh
    ranger
    nurl
    dnsutils
    wget
    yazi
    gnumake
    jq
    fastfetch
    claude-code
    devbox

    # Ops tools
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

  # btop with settings to mitigate crash bug in 1.4.x
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "nord";
      theme_background = false;
      update_ms = 1000;
      proc_sorting = "memory";
      proc_filter_kernel = true;
      show_gpu_info = "Off";
    };
  };

  programs.home-manager.enable = true;
  programs.htop.enable = true;

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = lib.mkDefault [ "aws" "git" "kubectl" "vi-mode" "docker" ];
      theme = lib.mkDefault "bira";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
