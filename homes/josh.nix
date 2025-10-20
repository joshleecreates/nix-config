{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [
    ./home.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.nurl
  ];

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "new-vm.local" = {
      checkHostIP = false;
    };
  };
}
