{ lib, ... }:

# Standalone home-manager config for josh@draper (NixOS workstation)
# CLI tools only - no desktop environment

{
  imports = [
    ../home/home.nix
  ];

  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "24.05";
}
