{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.moonlight;
in {
  options.modules.moonlight = {
    enable = mkEnableOption "Moonlight game streaming client with hardware acceleration";
  };

  config = mkIf cfg.enable {
    # Install Moonlight Qt client
    home.packages = with pkgs; [
      moonlight-qt
    ];

    # XDG desktop entry customization (optional)
    xdg.desktopEntries.moonlight = {
      name = "Moonlight";
      comment = "Stream games from your NVIDIA GameStream-enabled PC";
      exec = "moonlight-qt";
      icon = "moonlight";
      terminal = false;
      type = "Application";
      categories = [ "Game" "Network" ];
    };

    # Shell alias for checking hardware acceleration support
    programs.zsh.shellAliases = {
      vainfo = "vainfo";  # Check VA-API driver and capabilities
      moonlight-check = "vainfo && echo '\\nHardware acceleration ready for Moonlight'";
    };
  };
}
