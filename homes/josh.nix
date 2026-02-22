{ config, pkgs, lib, ... }:

{
  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "23.11";

  imports = [
    ./home.nix
  ];

  home.packages = [
    pkgs.nurl
    pkgs.ghostty.terminfo
    pkgs.claude-code
  ];

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    "new-vm.local" = {
      checkHostIP = false;
    };
  };
}
