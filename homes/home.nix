{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/k9s.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # shell
    pkgs.thefuck
    pkgs.oh-my-zsh
    pkgs.git
    pkgs.wget
    pkgs.gnumake
    pkgs.ranger
    pkgs.zoxide
    pkgs.fzf
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
