{ config, lib, pkgs, ... }:

let
  cfg = config.modules.fsTools;
in
{
  options.modules.fsTools.enable = lib.mkEnableOption "modern filesystem CLI replacements (eza, bat) and their aliases";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      eza
      bat
    ];

    programs.zsh.shellAliases = {
      ls = "eza --icons";
      # mkForce overrides the plain `ll = "ls -l"` from home/common/zsh.nix.
      ll = lib.mkForce "eza -l --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";
    };
  };
}
