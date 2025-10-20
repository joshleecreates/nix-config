{ config, pkgs, lib, ...}:
let
  users = [
    "joshlee"
    "work"
  ];

  # Create an attribute set for users.users
  usersConfig = builtins.listToAttrs (map (user: {
    name = user;
    value = {
      isHidden = false;
      shell = pkgs.zsh;
    };
  }) users);

  # Similarly, for home-manager.users
  homeManagerConfig = builtins.listToAttrs (map (user: {
    name = user;
    value = {
      imports = [ ../homes/${user}.nix ];
    };
  }) users);
in 
{
  imports = [
    ./common.nix
    ../modules/darwin/homebrew.nix
  ];


  # Users
  users.users = usersConfig;

  home-manager.users = homeManagerConfig;

  # Trusted Users
  nix.settings.trusted-users = [ "@admin" ] ++ users;

  # Extra Brews & Casks
  homebrew.brews = [
    # "doctl"
  ];

  homebrew.casks = [
    "obs" # stream / recoding software
  ];

  system.stateVersion = 5;
}
