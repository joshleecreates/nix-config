{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.herdr;
in {
  options.modules.herdr = {
    enable = mkEnableOption "herdr agent multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.herdr ];

    # Align keybindings with the tmux module so muscle memory carries over:
    # Ctrl-n prefix, prefix+| vertical split, prefix+- horizontal split,
    # prefix+, rename.
    #
    # Ctrl-h/j/k/l switch pane focus everywhere (shells, Neovim, any app).
    # herdr intercepts these before the focused pane, so Neovim does not receive
    # them; vim splits are navigated with the Neovim default Ctrl-w h/j/k/l.
    # Because pane focus lives on Ctrl-h/j/k/l, the prefix+h/j/k/l slots are free
    # for vim-style tab/workspace focus.
    #
    # prefix+h/l  focus tab left/right (previous/next in the tab bar)
    # prefix+j/k  focus workspace down/up (next/previous in the stack)
    # prefix+p/n  cycle agents (previous/next)
    # prefix+$    rename workspace
    # Ctrl-space  zoom the focused pane (no prefix)
    #
    # herdr only exposes previous/next_{tab,workspace} for tab/workspace
    # movement; these move to the adjacent tab/workspace (wrapping at the ends),
    # which is the closest thing to directional focus.
    xdg.configFile."herdr/config.toml".text = ''
      [keys]
      prefix = "ctrl+n"
      split_vertical = "prefix+|"
      split_horizontal = "prefix+minus"
      rename_tab = "prefix+,"
      focus_pane_left = "ctrl+h"
      focus_pane_down = "ctrl+j"
      focus_pane_up = "ctrl+k"
      focus_pane_right = "ctrl+l"

      # Focus tab left/right
      previous_tab = "prefix+h"
      next_tab = "prefix+l"

      # Focus workspace up/down, and rename
      previous_workspace = "prefix+k"
      next_workspace = "prefix+j"
      rename_workspace = "prefix+$"

      # Cycle agents
      previous_agent = "prefix+p"
      next_agent = "prefix+n"

      # Zoom the focused pane without the prefix
      zoom = "ctrl+space"

      # No sound when agents finish or request input
      [ui.sound]
      enabled = false
    '';
  };
}
