{ config, pkgs, lib, ... }:

# Josh's Framework 12 configuration - full desktop + Framework-specific

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../home/desktop.nix
    ../modules/home-manager/pi.nix
    ../modules/home-manager/herdr.nix
  ];

  # Desktop feature overrides
  modules.gaming.enable = true;
  modules.pi.enable = true;
  modules.herdr.enable = true;
  modules.zen-browser.enable = true;
  # Disable oh-my-zsh theme, use Starship instead
  programs.zsh.oh-my-zsh.theme = lib.mkForce "";
  modules.starship.enable = true;
  modules.starship.hostIcon = "💻"; # laptop → framework12

  home.packages = with pkgs; [
    beekeeper-studio
    moonlight-qt
    claude-code
    owncloud-client
    vcluster
  ];

  # Syncthing whitelist for the ~/.kube folder: sync only *.yaml cluster
  # definitions, never ~/.kube/config (a per-machine holder for the current
  # context), the credential cache, or discovery cache. First match wins, so
  # keeps are listed before the catch-all ignore.
  home.file.".kube/.stignore".text = ''
    !*.yaml
    !*/
    *
  '';

  # SSH host aliases for the other machines.
  programs.ssh = {
    enable = true;
    matchBlocks = {
      draper = {
        hostname = "draper";
        user = "josh";
      };
      kasti = {
        hostname = "workstation-kasti";
        user = "josh";
      };
      pdm = {
        hostname = "192.168.11.220";
        user = "root";
        proxyJump = "josh@workstation-kasti";
      };
    };
  };
}
