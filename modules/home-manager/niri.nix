{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.niri;

  # Spawns a command on the last (empty trailing) workspace, waits for its
  # window to map, then positions that workspace directly below the workspace
  # the command was activated from. With --maximize the new column is widened to
  # full width (niri's maximize-column, not real fullscreen).
  #
  # Usage: open-below-current [--maximize] <app-id> -- <command...>
  #
  # <app-id> is used only to detect that the new window has mapped (by watching
  # the count of windows with that app-id grow). See the Super+Shift+* binds.
  openBelowCurrent = pkgs.writeShellScriptBin "open-below-current" ''
    set -euo pipefail

    niri=${pkgs.niri}/bin/niri
    jq=${pkgs.jq}/bin/jq

    maximize=0
    if [ "''${1:-}" = "--maximize" ]; then maximize=1; shift; fi
    appid="$1"; shift
    [ "''${1:-}" = "--" ] && shift

    # Originating workspace (index + output), captured before we move focus.
    read -r orig out < <("$niri" msg -j workspaces \
      | "$jq" -r '(map(select(.is_focused)) | .[0]) | "\(.idx) \(.output)"')

    # Last (empty trailing) workspace on that output; focus it so the new
    # window maps there.
    last_idx=$("$niri" msg -j workspaces \
      | "$jq" -r --arg o "$out" '[.[] | select(.output == $o)] | max_by(.idx) | .idx')
    "$niri" msg action focus-workspace "$last_idx"

    # Spawn, then wait (up to ~10s) for a new window of this app-id to map.
    before=$("$niri" msg -j windows | "$jq" --arg a "$appid" '[.[] | select(.app_id == $a)] | length')
    "$@" >/dev/null 2>&1 &
    for _ in $(seq 1 100); do
      after=$("$niri" msg -j windows | "$jq" --arg a "$appid" '[.[] | select(.app_id == $a)] | length')
      [ "$after" -gt "$before" ] && break
      sleep 0.1
    done

    # Move the workspace (now holding the new window) to just below the origin.
    "$niri" msg action move-workspace-to-index "$((orig + 1))"

    # The new window is the focused column on its fresh workspace; widen it.
    [ "$maximize" = 1 ] && "$niri" msg action maximize-column
  '';

  # focus-or-spawn with optional maximize (full width) and below-current
  # placement. Focuses an existing window matching app-id + title regexes and
  # stops there (leaving its width alone). If none is open, spawns the command;
  # with --below the new window lands on a fresh workspace directly below the
  # current one; with maximize=1 its column is widened to full width once it maps
  # (niri's maximize-column, not real fullscreen). A fresh window is never
  # maximized, so the single toggle is safe. Used for Super+D and Super+S.
  #
  # Usage: focus-or-spawn-fs [--below] <app-id-re> <title-re> <0|1 maximize> -- <command...>
  focusOrSpawnFs = pkgs.writeShellScriptBin "focus-or-spawn-fs" ''
    set -euo pipefail

    niri=${pkgs.niri}/bin/niri
    jq=${pkgs.jq}/bin/jq

    below=0
    if [ "''${1:-}" = "--below" ]; then below=1; shift; fi
    appid="$1"; title="$2"; maximize="$3"; shift 3
    [ "''${1:-}" = "--" ] && shift

    # Focus an existing match if there is one, then stop.
    id=$("$niri" msg -j windows | "$jq" -r --arg a "$appid" --arg t "$title" \
      'first(.[] | select((.app_id // "" | test($a)) and (.title // "" | test($t))) | .id) // empty')
    if [ -n "$id" ]; then
      "$niri" msg action focus-window --id "$id"
      exit 0
    fi

    # None open. Remember existing matching ids so we can pick out the new one.
    before=$("$niri" msg -j windows | "$jq" -c --arg a "$appid" --arg t "$title" \
      '[.[] | select((.app_id // "" | test($a)) and (.title // "" | test($t))) | .id]')

    # For --below, focus the trailing empty workspace first (remember origin).
    if [ "$below" = 1 ]; then
      read -r orig out < <("$niri" msg -j workspaces \
        | "$jq" -r '(map(select(.is_focused)) | .[0]) | "\(.idx) \(.output)"')
      last_idx=$("$niri" msg -j workspaces \
        | "$jq" -r --arg o "$out" '[.[] | select(.output == $o)] | max_by(.idx) | .idx')
      "$niri" msg action focus-workspace "$last_idx"
    fi

    # Spawn and wait (up to ~10s) for the new matching window to map.
    "$@" >/dev/null 2>&1 &
    id=""
    for _ in $(seq 1 100); do
      id=$("$niri" msg -j windows | "$jq" -r --arg a "$appid" --arg t "$title" --argjson b "$before" \
        'first(.[]
           | select((.app_id // "" | test($a)) and (.title // "" | test($t)))
           | select(.id as $i | ($b | index($i)) | not)
           | .id) // empty')
      [ -n "$id" ] && break
      sleep 0.1
    done
    [ -z "$id" ] && exit 0

    [ "$below" = 1 ] && "$niri" msg action move-workspace-to-index "$((orig + 1))"
    if [ "$maximize" = 1 ]; then
      "$niri" msg action focus-window --id "$id"
      "$niri" msg action maximize-column
    fi
  '';

  # Moves the focused window to a fresh workspace directly below the current
  # one. See Super+Shift+N in niri-config.kdl.
  windowBelowCurrent = pkgs.writeShellScriptBin "window-below-current" ''
    set -euo pipefail

    niri=${pkgs.niri}/bin/niri
    jq=${pkgs.jq}/bin/jq

    # Originating workspace: index, output, and how many windows it holds. If
    # the focused window is the only one there, the origin workspace collapses
    # when we move the window out, shifting everything below it up by one.
    read -r orig out ws_id < <("$niri" msg -j workspaces \
      | "$jq" -r '(map(select(.is_focused)) | .[0]) | "\(.idx) \(.output) \(.id)"')
    win_count=$("$niri" msg -j windows \
      | "$jq" --argjson w "$ws_id" '[.[] | select(.workspace_id == $w)] | length')

    last_idx=$("$niri" msg -j workspaces \
      | "$jq" -r --arg o "$out" '[.[] | select(.output == $o)] | max_by(.idx) | .idx')

    # Move the focused window to the trailing workspace (focus follows).
    "$niri" msg action move-window-to-workspace "$last_idx"

    # Target index: just below origin, adjusting for origin collapse.
    if [ "$win_count" -le 1 ]; then target="$orig"; else target="$((orig + 1))"; fi
    "$niri" msg action move-workspace-to-index "$target"
  '';
in {
  options.modules.niri = {
    enable = mkEnableOption "Niri Wayland compositor";
  };

  config = mkIf cfg.enable {
    # Cursor theme configuration
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # Wayland packages
    home.packages = with pkgs; [
      xwayland-satellite  # XWayland support for Niri
      # wlr-randr - replaced by kanshi for automatic display profile switching
      pavucontrol  # Audio control
      networkmanagerapplet  # Network manager applet
      blueman  # Bluetooth manager
      rofimoji  # Emoji picker
      wvkbd  # Virtual keyboard for touchscreen mode
      polkit_gnome  # Polkit authentication agent
      openBelowCurrent  # Super+Shift+B/C/D/T: spawn app on a fresh workspace below current
      windowBelowCurrent  # Super+Shift+N: move focused window to a fresh workspace below current
      focusOrSpawnFs  # Super+D/Super+S: focus-or-spawn, maximize (full width) on fresh spawn
    ];

    # Niri configuration file
    xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;

    # Niri Wayland services
    services.swayidle.enable = true;


    # Disk automounting
    services.udiskie = {
      enable = true;
      automount = true;
    };

    # XWayland support: niri 25.11+ automatically spawns xwayland-satellite
    # and exports DISPLAY. The package is kept in PATH above.

    # Polkit agent for authentication dialogs (required for elevated permissions)
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Niri-specific environment variables
    home.sessionVariables = {
      # Wayland session
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "niri";

      # Enable Wayland support for Electron/Chromium apps
      NIXOS_OZONE_WL = "1";

      # Force apps to prefer Wayland when available
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # Mozilla/Firefox Wayland
      MOZ_ENABLE_WAYLAND = "1";

      # DISPLAY is set automatically by niri when it spawns xwayland-satellite
    };
  };
}
