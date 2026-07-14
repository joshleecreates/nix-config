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

  # Syncthing — runs as a systemd user service (standalone home-manager, so
  # no NixOS service module here; it defaults to ~/.config/syncthing and
  # ~/.local/share/syncthing running as josh).
  # Single node for now; pair with framework12 via the web UI (or add
  # settings.devices) once device IDs are exchanged.
  # NOTE: ~/repos contains git working trees; syncing .git across machines
  # races with git and produces sync-conflict files. Scope the folder or
  # exclude .git before both nodes are actively syncing.
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      folders."repos" = {
        id = "repos";
        label = "repos";
        path = "/home/josh/repos";
      };
    };
  };
}
