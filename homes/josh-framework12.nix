{ config, pkgs, lib, ... }:

# Josh's Framework 12 configuration - full desktop + Framework-specific

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../home/desktop.nix
    ../modules/home-manager/pi.nix
  ];

  # Desktop feature overrides
  modules.gaming.enable = true;
  modules.pi.enable = true;

  home.packages = with pkgs; [
    moonlight-qt
    claude-code
  ];
}
