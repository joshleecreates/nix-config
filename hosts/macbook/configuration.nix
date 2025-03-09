{ config, pkgs, inputs, system, ...}:

let 
  user = "josh"; 
  systemPackages = [
    inputs.flox.packages.${pkgs.system}.default
  ];
in 

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  imports = [
    ../../modules/darwin/homebrew.nix
  ];
  users.users.${user} = {
    isHidden = false;
    shell = pkgs.zsh;
  };

  home-manager.users.${user} = {
    imports = [ ../../homes/joshlee.nix ];
  };

  environment.systemPackages = systemPackages;

  services.nix-daemon.enable = true;

  nix = {
    settings.trusted-users = [ "@admin" "${user}" ];
    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nix.settings = {
    substituters = [
      "https://cache.flox.dev"
    ];
    trusted-public-keys = [
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
  };

  system.checks.verifyNixPath = false;

  system.stateVersion = 4;
}
