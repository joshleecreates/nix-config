{ config, lib, pkgs, ... }:

let
  cfg = config.modules.pi;
in
{
  options.modules.pi = {
    enable = lib.mkEnableOption "pi.dev coding agent";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      ripgrep
      fd
    ];

    home.file.".npmrc".text = "prefix=~/.npm-global\n";

    home.sessionPath = [ "$HOME/.npm-global/bin" ];

    programs.zsh.initContent = ''
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';

    home.activation.install-pi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      export npm_config_prefix="$HOME/.npm-global"
      mkdir -p "$HOME/.npm-global"
      ${pkgs.nodejs}/bin/npm list -g @earendil-works/pi-coding-agent &>/dev/null || \
        ${pkgs.nodejs}/bin/npm install -g @earendil-works/pi-coding-agent
    '';
  };
}
