{...}: {
  # Source aerospace config from the home-manager store
  home.file.".aerospace.toml".text = " 
    # Start AeroSpace at login
    start-at-login = true

    # Normalization settings
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Accordion layout settings
    accordion-padding = 30

    # Default root container settings
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    # Mouse follows focus settings
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    on-focus-changed = ['move-mouse window-lazy-center']

    # Automatically unhide macOS hidden apps
    automatically-unhide-macos-hidden-apps = false

    # Run Sketchybar together with AeroSpace
    # sketchbar has a built-in detection of already running process,
    # so it won't be run twice on AeroSpace restart
    after-startup-command = ['exec-and-forget sketchybar']

    # Notify Sketchybar about workspace change
    exec-on-workspace-change = ['/bin/bash', '-c',
        'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
    ]

    # Key mapping preset
    [key-mapping]
    preset = 'qwerty'

    # Gaps settings
    [gaps]
    inner.horizontal = 8
    inner.vertical =   8
    outer.left =       8
    outer.bottom =     8
    outer.top =        8
    outer.right =      8

    # Main mode bindings
    [mode.main.binding]
    # Launch applications
    alt-shift-period = 'exec-and-forget open -na ghostty'
    #TODO: Launch Safari new window 

    # Window management
    alt-q = 'close'
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-z = 'fullscreen'
    alt-shift-enter = 'fullscreen'
    alt-shift-space = 'fullscreen'

    # Focus movement
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'
    alt-o = 'focus-monitor --wrap-around next'
    alt-i = 'focus-monitor --wrap-around prev'

    # Window movement
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'


    # Workspace management
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'
    alt-0 = 'workspace 0'
    alt-m = 'workspace m'
    alt-b = 'workspace b'
    alt-s = 'workspace s'
    alt-t = 'workspace t'
    alt-r = 'workspace r'
    alt-n = 'workspace n'

    # Move windows to workspaces
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'
    alt-shift-0 = 'move-node-to-workspace 0'
    alt-shift-m = 'move-node-to-workspace m'
    alt-shift-b = 'move-node-to-workspace b'
    alt-shift-s = 'move-node-to-workspace s'
    alt-shift-t = 'move-node-to-workspace t'
    alt-shift-r = 'move-node-to-workspace r'
    alt-shift-n = 'move-node-to-workspace n'

    # Workspace navigation
    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    # Enter service mode
    alt-shift-semicolon = 'mode service'

    # Service mode bindings
    [mode.service.binding]
    # Resize windows
    minus = 'resize smart -50'
    equal = 'resize smart +50'

    # Reload config and exit service mode
    esc = ['reload-config', 'mode main']

    # Reset layout
    r = ['flatten-workspace-tree', 'mode main']

    # Toggle floating/tiling layout
    f = ['layout floating tiling', 'mode main']

    # Close all windows but current
    backspace = ['close-all-windows-but-current', 'mode main']

    # Join with adjacent windows
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']

    # Window detection rules
    [[on-window-detected]]
    if.app-id = 'com.obsproject.obs-studio'
    run = 'move-node-to-workspace 6'

    [[on-window-detected]]
    if.app-id = 'us.zoom.xos'
    run = 'move-node-to-workspace 6'
  ";
}
