{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.gaming = {
    enable = mkEnableOption "gaming packages and configuration";
  };

  config = mkIf config.modules.gaming.enable {
    home.packages = with pkgs; [
      (heroic.override {
        extraPkgs = pkgs: [
          pkgs.gamescope
          pkgs.gamemode
        ];
      })
    ];
  };
}
