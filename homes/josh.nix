{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/k9s.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.thefuck
    pkgs.git
    pkgs.gh
    pkgs.ranger
    pkgs.nurl
    pkgs.btop
    pkgs.dnsutils
    pkgs.wget
    pkgs.gnumake
    pkgs.kubectl
    pkgs.kubectx
    pkgs.opentofu
    pkgs.ansible
    pkgs.talosctl
    pkgs.argocd
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    T_REPOS_DIR = "$HOME/repos";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.htop.enable = true;
  programs.ssh.enable = true;
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = lib.mkDefault [ "aws" "git" "thefuck" "kubectl" "vi-mode" "docker" ];
      theme = lib.mkDefault "bira";
    };
  };
}
