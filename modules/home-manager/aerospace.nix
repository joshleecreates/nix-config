{...}: 
let
  workspaces = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "0"
    "a"
    "b"
    "m"
    "n"
    "r"
    "s"
    "t"
  ];
  
  # Generate workspace management bindings
  workspaceBindings = builtins.concatStringsSep "\n" (builtins.map 
    (ws: "alt-${ws} = 'workspace ${ws}'") 
    workspaces);
    
  # Generate move-to-workspace bindings  
  moveToWorkspaceBindings = builtins.concatStringsSep "\n" (builtins.map 
    (ws: "alt-shift-${ws} = 'move-node-to-workspace ${ws}'") 
    workspaces);
in
{
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
    # on-focus-changed = ['move-mouse window-lazy-center']

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
    ${workspaceBindings}

    # Move windows to workspaces
    ${moveToWorkspaceBindings}

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
