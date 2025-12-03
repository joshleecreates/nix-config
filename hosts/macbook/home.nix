{ pkgs, ... }:
{
  imports = [
    ../../homes/josh.nix
  ];

  home.packages = [
    pkgs.awscli2
  ];

  programs.zsh = {
    initContent = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
