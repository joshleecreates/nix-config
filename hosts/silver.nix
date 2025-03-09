{ config, pkgs, ...}:

let user = "joshlee"; in 

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

  system.stateVersion = 4;
}
