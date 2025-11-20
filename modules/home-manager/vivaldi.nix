{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.vivaldi;
in {
  options.modules.vivaldi = {
    enable = mkEnableOption "Vivaldi browser";

    onePasswordIntegration = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 1Password native messaging integration";
    };
  };

  config = mkIf cfg.enable {
    programs.vivaldi = {
      enable = true;
    };

    # Note: We don't create the native messaging host manifest here
    # 1Password desktop app creates it automatically when it starts
    # We just need vivaldi-bin in /etc/1password/custom_allowed_browsers (done in system config)
  };
}
