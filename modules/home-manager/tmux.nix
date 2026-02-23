{ pkgs, lib, config, ... }:

let
  cfg = config.modules.tmux;

  # Theme color palettes
  themes = {
    nord = {
      bg = "default";
      fg = "#eceff4";
      accent = "#88c0d0";
      accentFg = "#2e3440";
      secondary = "#81a1c1";
      muted = "#4c566a";
      mutedFg = "#d8dee9";
    };
    rose-pine = {
      bg = "default";
      fg = "#e0def4";
      accent = "#c4a7e7";
      accentFg = "#191724";
      secondary = "#ebbcba";
      muted = "#26233a";
      mutedFg = "#e0def4";
    };
  };

  theme = themes.${cfg.theme};
in
{
  options.modules.tmux = {
    enable = lib.mkEnableOption "Tmux terminal multiplexer";
    theme = lib.mkOption {
      type = lib.types.enum [ "nord" "rose-pine" ];
      default = "nord";
      description = "Color theme for tmux status bar";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      sensibleOnTop = false;
      shortcut = "n";
      keyMode = "vi";
      clock24 = true;
      customPaneNavigationAndResize = true;
      plugins = with pkgs.tmuxPlugins; [
        yank
        resurrect
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
      ];
      extraConfig = ''
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'
        set -g detach-on-destroy off
        set-option -g status-left-length 40
        set-option -g status-right-length 80

        # Status bar with rounded bubbles
        set -g status-style "bg=${theme.bg},fg=${theme.fg}"

        # Left side - session name with rounded bubble
        set -g status-left "#[bg=${theme.bg},fg=${theme.accent}]#[bg=${theme.accent},fg=${theme.accentFg},bold] #S #[bg=${theme.bg},fg=${theme.accent}] "

        # Right side - host, date, time with rounded bubbles
        set -g status-right ""

        # Window status format with rounded bubbles
        set -g window-status-format "#[bg=${theme.bg},fg=${theme.muted}]#[bg=${theme.muted},fg=${theme.mutedFg}] #I #W #[bg=${theme.bg},fg=${theme.muted}]"
        set -g window-status-current-format "#[bg=${theme.bg},fg=${theme.secondary}]#[bg=${theme.secondary},fg=${theme.accentFg},bold] #I #W #[bg=${theme.bg},fg=${theme.secondary}]"

        set -g window-status-separator " "
        # switch panes using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # shift arrow to switch windows
        bind-key -r b previous-window
        bind-key -r n next-window

        # resizing panes
        bind-key -r j resize-pane -D 5
        bind-key -r k resize-pane -U 5
        bind-key -r h resize-pane -L 5
        bind-key -r l resize-pane -R 5

        # don't rename windows automatically
        set-option -g allow-rename off

        # split panes using | and -
        bind | split-window -h
        bind - split-window -v

        # Enable mouse mode (tmux 2.1 and above)
        set -g mouse on

        # vim key bindings
        # Smart pane switching with awareness of Vim splits.
        # See: https://github.com/christoomey/vim-tmux-navigator

        # decide whether we're in a Vim process
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'

        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -n 'C-Space' if-shell "$is_vim" 'send-keys C-Space' 'select-pane -t:.+'

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
        bind-key -T copy-mode-vi 'C-Space' select-pane -t:.+

        bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
        bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

        unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode when dragging with mouse

        # remove delay for exiting insert mode with ESC in Neovim
        set -sg escape-time 10
      '';
    };
  };
}
