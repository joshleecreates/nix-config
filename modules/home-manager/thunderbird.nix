{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.thunderbird;
in {
  options.modules.thunderbird = {
    enable = mkEnableOption "Thunderbird email client";

    onePasswordIntegration = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 1Password native messaging integration";
    };
  };

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };

    # 1Password native messaging host for Thunderbird
    home.file.".thunderbird/native-messaging-hosts/com.1password.1password.json" = mkIf cfg.onePasswordIntegration {
      source = "${pkgs._1password-gui}/share/1password/native-messaging-hosts/thunderbird/com.1password.1password.json";
    };
  };
}
