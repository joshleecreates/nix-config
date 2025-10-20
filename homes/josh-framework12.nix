{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/k9s.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/ghostty.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Development tools
    pay-respects
    git
    gh
    ranger
    nurl
    btop
    dnsutils
    wget
    gnumake
    kubectl
    kubectx
    opentofu
    ansible
    talosctl
    argocd
    
    # Framework 12 specific tools
    powertop
    brightnessctl
    acpi
    
    # Desktop tools
    firefox
    chromium
    slack
    ghostty
    
    # System utilities
    pavucontrol
    networkmanagerapplet
    blueman
    
    # Media
    mpv
    spotify
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
      plugins = lib.mkDefault [ "aws" "git" "kubectl" "vi-mode" "docker" ];
      theme = lib.mkDefault "bira";
    };
    shellAliases = {
      # Battery and power management aliases for Framework laptop
      battery = "acpi -b";
      powersave = "sudo powerprofilesctl set power-saver";
      balanced = "sudo powerprofilesctl set balanced";
      performance = "sudo powerprofilesctl set performance";
    };
  };

  # Framework 12 specific services
  services.udiskie = {
    enable = true;
    automount = true;
  };

  # Power management
  services.cbatticon = {
    enable = true;
    criticalLevelPercent = 10;
    commandCriticalLevel = ''notify-send "Battery critical" "Battery level is critically low"'';
  };
}
