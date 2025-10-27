{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    shortcut = "n";
    keyMode = "vi";
    clock24 = true;
    customPaneNavigationAndResize = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      nord
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
      set -g default-terminal "screen-256color"
      set -g detach-on-destroy off
      set-option -g status-left-length 40
      set-option -g status-right-length 80

      # Status bar with rounded bubbles (Nord colors)
      set -g status-style "bg=default,fg=#eceff4"

      # Left side - session name with rounded bubble
      set -g status-left "#[bg=default,fg=#88c0d0]#[bg=#88c0d0,fg=#2e3440,bold] #S #[bg=default,fg=#88c0d0] "

      # Right side - host, date, time with rounded bubbles
      set -g status-right ""

      # Window status format with rounded bubbles
      set -g window-status-format "#[bg=default,fg=#4c566a]#[bg=#4c566a,fg=#d8dee9] #I #W #[bg=default,fg=#4c566a]"
      set -g window-status-current-format "#[bg=default,fg=#81a1c1]#[bg=#81a1c1,fg=#2e3440,bold] #I #W #[bg=default,fg=#81a1c1]"

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
}
