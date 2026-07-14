{ lib, pkgs, ... }:

# Standalone home-manager config for josh@draper (NixOS workstation)
# CLI tools only - no desktop environment

{
  imports = [
    ../home/home.nix
    ../modules/home-manager/pi.nix
  ];

  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ghostty.terminfo
    claude-code
    nerd-fonts.jetbrains-mono
    eza
    bat
  ];

  fonts.fontconfig.enable = true;

  modules.pi.enable = true;

  # Use rose-pine theme
  modules.neovim.theme = "rose-pine";
  modules.tmux.theme = "rose-pine";

  # Disable oh-my-zsh theme, use Starship instead
  programs.zsh.oh-my-zsh.theme = lib.mkForce "";

  programs.zsh.shellAliases = {
    hms = "home-manager switch --flake ~/nix-config#josh@draper";
    ls = "eza --icons";
    ll = lib.mkForce "eza -l --icons";
    la = "eza -la --icons";
    lt = "eza --tree --icons";
    cat = "bat";
  };

  modules.starship.enable = true;
}
