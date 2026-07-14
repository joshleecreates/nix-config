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

  home.packages = with pkgs; [
    beekeeper-studio
    moonlight-qt
    claude-code
    owncloud-client
    vcluster
  ];
}
