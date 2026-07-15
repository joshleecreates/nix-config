{ lib, pkgs, ... }:

# Standalone home-manager config for josh@kasti (NixOS workstation)
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
    hms = "home-manager switch --flake ~/nix-config#josh@kasti";
  };

  modules.starship.enable = true;
  modules.starship.hostIcon = "🚀"; # rocket → kasti (workstation-kasti)

  # Syncthing — runs as a systemd user service (standalone home-manager, so
  # no NixOS service module here; it defaults to ~/.config/syncthing and
  # ~/.local/share/syncthing running as josh).
  # Peering is declared here (overrideDevices/overrideFolders = true means the
  # web UI can't durably add peers — every rebuild/restart resets to this).
  # Peers are pinned to their Tailscale IPs (+ dynamic fallback).
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
        draper = {
          id = "DREZGHY-QCPMOHH-3EQ5LS2-EMRCCP4-LZUJTS2-TA4K7WL-ONYYFDW-F42VIQ6";
          addresses = [ "tcp://100.68.102.73:22000" "dynamic" ];
        };
      };
      folders."repos" = {
        id = "repos";
        label = "repos";
        path = "/home/josh/repos";
        devices = [ "framework12" "draper" ];
      };
      folders."kube" = {
        id = "kube";
        label = "kube";
        path = "/home/josh/.kube";
        devices = [ "framework12" ];
      };
    };
  };

  # Syncthing ignores for ~/repos. The stub just pulls in .stignore-shared — a
  # regular file that lives inside the synced folder, so the actual patterns
  # (root-owned/churning container data dirs, node_modules, etc.) propagate to
  # every host via Syncthing itself. Edit .stignore-shared on any machine.
  home.file."repos/.stignore".text = "#include .stignore-shared\n";

  # Syncthing whitelist for the ~/.kube folder: sync only *.yaml cluster
  # definitions, never ~/.kube/config (a per-machine holder for the current
  # context), the credential cache, or discovery cache. First match wins, so
  # keeps are listed before the catch-all ignore.
  home.file.".kube/.stignore".text = ''
    !*.yaml
    !*/
    *
  '';
}
