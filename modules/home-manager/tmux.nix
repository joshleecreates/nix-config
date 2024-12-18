{ pkgs, ... }:
let 
  t-smart-tmux-session-manager = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "t-smart-tmux-session-manager";
      version = "unstable-2023-12-23";
      src = pkgs.fetchFromGitHub {
        owner = "joshmedeski";
        repo = "t-smart-tmux-session-manager";
        rev = "629d5629ac50302ca6f0f3a44228fd73dedd8873";
        hash = "sha256-cfvO4pzQOWJ9NE4/M/qXj0Rdbg/+wKr/qRS4rNKurDY=";
      };
    };
in
{
  home.packages = [
    pkgs.zoxide
    pkgs.fzf
    t-smart-tmux-session-manager.src
  ];
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    shortcut = "n";
    keyMode = "vi";
    clock24 = true;
    customPaneNavigationAndResize = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      t-smart-tmux-session-manager
      nord
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];
    extraConfig = ''
      set -g default-terminal "screen-256color"

      set-option -g status-left-length 40
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

      # dont ask to kill pane
      # bind-key x kill-pane
    '';
  };
}
