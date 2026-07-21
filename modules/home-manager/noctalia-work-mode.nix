{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.noctalia-work-mode;
in {
  options.modules.noctalia-work-mode = {
    enable = mkEnableOption "Work Mode toggle plugin for the noctalia bar";
  };

  config = mkIf cfg.enable {
    # Ship the plugin payload. Individual files become read-only nix-store symlinks,
    # but the parent directory stays writable so noctalia can create its own
    # plugins/work-mode/settings.json for persistent toggle state.
    xdg.configFile."noctalia/plugins/work-mode/manifest.json".source =
      ./noctalia/work-mode/manifest.json;
    xdg.configFile."noctalia/plugins/work-mode/BarWidget.qml".source =
      ./noctalia/work-mode/BarWidget.qml;

    # Enable the plugin (writes ~/.config/noctalia/plugins.json). Keep the default
    # source so noctalia's plugin browser still works.
    # Note: this makes plugins.json a read-only nix symlink, so GUI-installed plugins
    # won't persist — consistent with settings.json already being nix-managed.
    programs.noctalia-shell.plugins = {
      version = 2;
      states.work-mode.enabled = true;
      sources = [{
        name = "Noctalia Plugins";
        url = "https://github.com/noctalia-dev/noctalia-plugins";
        enabled = true;
      }];
    };
    # noctalia writes plugins.json itself on first run; take over managing it.
    xdg.configFile."noctalia/plugins.json".force = true;

    # Qt's QML disk cache is keyed by file path + mtime, but every nix-store file
    # has a constant epoch mtime — so Qt keeps running a stale compiled copy of the
    # plugin QML and silently ignores updates across rebuilds. Clear noctalia's QML
    # cache on activation so plugin changes actually take effect (noctalia recompiles
    # on next start). Restart noctalia-shell after switching to pick up changes.
    home.activation.clearNoctaliaQmlCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -rf "$HOME/.cache/noctalia-qs/qmlcache"
    '';
  };
}
