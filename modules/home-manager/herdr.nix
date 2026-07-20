{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.herdr;
in {
  options.modules.herdr = {
    enable = mkEnableOption "herdr agent multiplexer";
  };

  config = mkIf cfg.enable {
    # herdr's `s` (below) replaces sesh's tmux workflow on every host where
    # herdr is enabled, so turn sesh off to stop its `s()` from shadowing ours.
    # herdr declares its own copies of the tools sesh used to supply — zoxide
    # and fzf, plus the zoxide shell init — so nothing is lost by disabling it.
    modules.sesh.enable = lib.mkForce false;

    home.packages = [ pkgs.herdr pkgs.zoxide pkgs.fzf ];

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

    # `s` — herdr's answer to sesh. Like sesh, it uses fzf to fuzzy-pick a
    # recently-visited directory (frecency-ranked by zoxide), but instead of a
    # tmux session it opens a herdr workspace rooted at that directory.
    #
    #   s              pick a dir with fzf, then open a workspace there
    #   s <query>      resolve <query> to a dir via zoxide, skip the picker
    #
    # Inside a running herdr session (HERDR_ENV=1) this creates a new focused
    # workspace over the socket API. Outside one, it cd's to the dir and boots
    # herdr so the initial workspace is rooted there.
    #
    # The zoxide init below installs the chpwd hook that records visited
    # directories into the frecency database that `zoxide query` reads.
    programs.zsh.initContent = ''
      eval "$(zoxide init zsh)"

      function s() {
        local dir
        if [ "$#" -gt 0 ]; then
          dir=$(zoxide query -- "$@") || return
        else
          dir=$(zoxide query -l | fzf --height 40% --reverse \
            --prompt 'workspace > ') || return
        fi
        [ -n "$dir" ] || return
        if [ -n "$HERDR_ENV" ]; then
          herdr workspace create --cwd "$dir" --focus >/dev/null
        else
          cd "$dir" && herdr
        fi
      }
    '';
  };
}
