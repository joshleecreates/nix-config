{ lib, pkgs, ... }:

# Standalone home-manager config for josh@draper (NixOS workstation)
# CLI tools only - no desktop environment

{
  imports = [
    ../home/home.nix
  ];

  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    claude-code
  ];
}
