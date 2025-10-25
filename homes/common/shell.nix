{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/zsh.nix
    ../../modules/home-manager/sesh.nix
  ];

  # Enable modules
  modules.sesh.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Standard Tools
    pay-respects
    git
    gh
    ranger
    nurl
    btop
    dnsutils
    wget
    yazi
    gnumake
    jq
    btop
    fastfetch
    claude-code
    devbox
  ];

  # Let Home Manager install and manage itself.
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
