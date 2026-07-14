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
  ];

  fonts.fontconfig.enable = true;

  modules.pi.enable = true;

  # Use rose-pine theme
  modules.neovim.theme = "rose-pine";
  modules.tmux.theme = "rose-pine";

  # Disable oh-my-zsh theme, use Starship instead
  programs.zsh.oh-my-zsh.theme = lib.mkForce "";

  # eza/bat and their aliases now come from modules.fsTools (enabled in home.nix).
  programs.zsh.shellAliases = {
    hms = "home-manager switch --flake ~/nix-config#josh@draper";
  };

  modules.starship.enable = true;
}
