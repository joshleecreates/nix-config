{ config, pkgs, lib, ...}:

let user = "josh"; in 

{
  imports = [
    ./common.nix
    ../modules/darwin/homebrew.nix
  ];

  # Users
  users.users.${user} = {
    isHidden = false;
    shell = pkgs.zsh;
  };

  home-manager.users.${user} = {
    imports = [ ../homes/joshlee.nix ];
    home.username = lib.mkForce user;
    home.homeDirectory = lib.mkForce "/Users/${user}";
    home.stateVersion = lib.mkForce "23.11";
 };


  # Trusted Users
  nix.settings.trusted-users = [ "@admin" "${user}" ];

  # Extra Brews & Casks
  homebrew.brews = [
    # "doctl"
  ];

  homebrew.casks = [
    # "obs" # stream / recoding software
  ];

  system.stateVersion = 5;
}
