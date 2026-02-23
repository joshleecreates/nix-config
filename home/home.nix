{ config, pkgs, lib, ... }:

# Base home configuration - CLI tools for all systems
# Import this for servers, headless machines, or as base for desktop/macos

{
  imports = [
    # Common configs (always-on)
    ./common/git.nix
    ./common/zsh.nix
    # CLI tools
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/sesh.nix
    # DevOps tools
    ../modules/home-manager/devops.nix
  ];

  # Enable modules
  modules.neovim.enable = true;
  modules.tmux.enable = true;
  modules.sesh.enable = true;
  modules.devops.enable = true;

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
    tree
    fastfetch
    devbox
  ];

  programs.home-manager.enable = true;
  programs.htop.enable = true;

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };


  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
