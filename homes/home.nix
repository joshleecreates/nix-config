{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/home-manager/git.nix
    ../modules/home-manager/k9s.nix
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/sesh.nix
    ../modules/home-manager/k8s-prompt.nix
  ];

  home.packages = [
    # shell
    pkgs.thefuck
    pkgs.oh-my-zsh
    pkgs.git
    pkgs.wget
    pkgs.gnumake
    pkgs.ranger
    pkgs.gh

    # lang servers
    pkgs.vscode-langservers-extracted
    pkgs.elixir
    pkgs.elixir-ls

    # devops
    pkgs.opentofu
    pkgs.awscli2
    pkgs.kubectl
    pkgs.kubectx
    pkgs.talosctl
    pkgs.argocd
    pkgs.cilium-cli
    pkgs.clickhouse
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    T_REPOS_DIR = "$HOME/repos";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.htop = {
    enable = true;
  };

  programs.zsh = {
    initExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
