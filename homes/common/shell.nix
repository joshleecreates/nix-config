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
    dnsutils
    wget
    yazi
    gnumake
    jq
    fastfetch
    claude-code
    devbox
  ];

  # btop with settings to mitigate crash bug in 1.4.x
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "nord";
      theme_background = false;
      update_ms = 1000;  # slower updates reduce race condition
      proc_sorting = "memory";
      proc_filter_kernel = true;
    };
  };

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
