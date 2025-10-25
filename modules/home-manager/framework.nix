{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.framework;
in {
  options.modules.framework = {
    enable = mkEnableOption "Framework laptop specific configuration";
  };

  config = mkIf cfg.enable {
    # Framework laptop specific packages
    home.packages = with pkgs; [
      powertop
      brightnessctl
      acpi
    ];

    # Power management - battery icon
    services.cbatticon = {
      enable = true;
      criticalLevelPercent = 10;
      commandCriticalLevel = ''notify-send "Battery critical" "Battery level is critically low"'';
    };

    # Framework laptop shell aliases
    programs.zsh.shellAliases = {
      battery = "acpi -b";
      powersave = "sudo powerprofilesctl set power-saver";
      balanced = "sudo powerprofilesctl set balanced";
      performance = "sudo powerprofilesctl set performance";
    };
  };
}
