{ pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Lee";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAg/E2UkXORp58O3zxp0dQird+UcvdJkCpKbZj5+ccmh josh@joshuamlee.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqNWMAWBBWiJJK+u2J78H64NLFo4zvQNPg45F3Gv+57 josh@joshuamlee.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHHvxOTX0LSZh1HbKiAx5zZwXR7OvhbgG3bTbwOsTqGV josh@joshuamlee.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTo7OPWSsPKdxz69sr89NYqKYhYGeyKSnpmY7xPmz2n josh@pop-os"
    ];
  };
}
