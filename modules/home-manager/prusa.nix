{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.prusa;
in {
  options.modules.prusa = {
    enable = mkEnableOption "Prusa 3D printing software";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.prusa-slicer ];

    # Desktop entry with URL scheme handler for OAuth callbacks
    xdg.desktopEntries.prusa-slicer = {
      name = "PrusaSlicer";
      genericName = "3D Printing Slicer";
      comment = "G-code generator for 3D printers";
      exec = "prusa-slicer %u";
      icon = "PrusaSlicer";
      categories = [ "Graphics" "3DGraphics" "Engineering" ];
      mimeType = [ "x-scheme-handler/prusaslicer" ];
    };
  };
}
