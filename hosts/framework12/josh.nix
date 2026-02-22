{ config, pkgs, lib, ... }:

# Josh's Framework 12 configuration - full desktop + Framework-specific

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../../homes/desktop.nix
    ./displays.nix
  ];

  # Desktop feature overrides
  modules.gaming.enable = true;

  home.packages = with pkgs; [
    moonlight-qt
  ];
}
