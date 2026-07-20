{ lib, pkgs, ... }:

# Standalone home-manager config for josh@draper (NixOS workstation)
# CLI tools only - no desktop environment

{
  imports = [
    ../home/home.nix
    ../modules/home-manager/pi.nix
    ../modules/home-manager/herdr.nix
  ];

  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    ghostty.terminfo
    bitwarden-cli
    bws
    claude-code
    tea
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  modules.pi.enable = true;
  modules.herdr.enable = true;

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
  modules.starship.hostIcon = "⌨️"; # keyboard → draper

  # Syncthing — runs as a systemd user service (standalone home-manager, so
  # no NixOS service module here; it defaults to ~/.config/syncthing and
  # ~/.local/share/syncthing running as josh).
  # Peering is declared here (overrideDevices/overrideFolders = true means the
  # web UI can't durably add peers — every rebuild/restart resets to this).
  # Peers are pinned to their Tailscale IPs (+ dynamic fallback). draper syncs
  # repos only (not kube).
  # NOTE: ~/repos contains git working trees; syncing .git across machines
  # races with git and produces sync-conflict files. Revisit (exclude .git or
  # scope the folder) if sync-conflict files start appearing.
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        framework12 = {
          id = "J3ASMN7-CPYGW5C-QQMGN7Q-OBSGFTW-PL6LKW6-6JKMM5X-CR5QUR3-LX2LEAW";
          addresses = [ "tcp://100.120.100.102:22000" "dynamic" ];
        };
        kasti = {
          id = "INZN3IU-ZFMNH4F-OHLVDLD-DIXCYZJ-SX5MTAD-HNA56F2-HSDBNS3-EYIEDAI";
          addresses = [ "tcp://100.122.202.21:22000" "dynamic" ];
        };
      };
      folders."repos" = {
        id = "repos";
        label = "repos";
        path = "/home/josh/repos";
        devices = [ "framework12" "kasti" ];
      };
    };
  };

  # Syncthing ignores for ~/repos. The stub just pulls in .stignore-shared — a
  # regular file that lives inside the synced folder, so the actual patterns
  # (root-owned/churning container data dirs, node_modules, etc.) propagate to
  # every host via Syncthing itself. Edit .stignore-shared on any machine.
  home.file."repos/.stignore".text = "#include .stignore-shared\n";
}
