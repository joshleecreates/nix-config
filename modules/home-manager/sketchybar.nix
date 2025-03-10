{...}: {
  home.file.".config/sketchybar/sketchybarrc".executable = true;
  home.file.".config/sketchybar/sketchybarrc".text = ''
    ##### Changing Defaults #####
    # We now change some default values, which are applied to all further items.
    # For a full list of all available item properties see:
    # https://felixkratz.github.io/SketchyBar/config/items

    default=(
      padding_left=5
      padding_right=5
      icon.font="Hack Nerd Font:Bold:17.0"
      label.font="Hack Nerd Font:Bold:14.0"
      # label.font="SF Pro:Bold:17.0"
      # label.y_offset="-2"
      icon.color=0xffffffff
      label.color=0xffffffff
      icon.padding_left=4
      icon.padding_right=4
      label.padding_left=4
      label.padding_right=4
    )
    sketchybar --default "''${default[@]}"

    sketchybar --add event aerospace_workspace_change

    for sid in $(aerospace list-workspaces --all); do
        sketchybar --add item space.$sid left \
            --subscribe space.$sid aerospace_workspace_change \
            --set space.$sid \
            background.color=0x44ffffff \
            background.corner_radius=5 \
            background.height=20 \
            background.drawing=off \
            label="$sid" \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/aerospace.sh $sid"
    done

    PLUGIN_DIR="$CONFIG_DIR/plugins"

    ##### Bar Appearance #####
    # Configuring the general appearance of the bar.
    # These are only some of the options available. For all options see:
    # https://felixkratz.github.io/SketchyBar/config/bar
    # If you are looking for other colors, see the color picker:
    # https://felixkratz.github.io/SketchyBar/config/tricks#color-picker

    sketchybar --bar position=top height=40 blur_radius=30 color=0x40000000


    ##### Adding Left Items #####
    # We add some regular items to the left side of the bar, where
    # only the properties deviating from the current defaults need to be set

    sketchybar --add item chevron left \
               --set chevron icon= label.drawing=off \
               --add item front_app left \
               --set front_app icon.drawing=off script="$PLUGIN_DIR/front_app.sh" \
               --subscribe front_app front_app_switched

    # E V E N T S
    # sketchybar -m --add event window_focus \
    #               --add event title_change
    #
    # # W I N D O W  T I T L E
    # sketchybar -m --add item title left \
    #               --set title script="$HOME/.config/sketchybar/plugins/window_title.sh" \
    #               --subscribe title window_focus front_app_switched space_change title_change
    ##### Adding Right Items #####
    # In the same way as the left items we can add items to the right side.
    # Additional position (e.g. center) are available, see:
    # https://felixkratz.github.io/SketchyBar/config/items#adding-items-to-sketchybar

    # Some items refresh on a fixed cycle, e.g. the clock runs its script once
    # every 10s. Other items respond to events they subscribe to, e.g. the
    # volume.sh script is only executed once an actual change in system audio
    # volume is registered. More info about the event system can be found here:
    # https://felixkratz.github.io/SketchyBar/config/events

    sketchybar -m --add item mic right \
    sketchybar -m --set mic update_freq=3 \
                  --set mic width=50 \
                  --set mic align="center" \
                  --set mic script="~/.config/sketchybar/plugins/mic.sh" \
                  --set mic click_script="~/.config/sketchybar/plugins/mic_click.sh"
    sketchybar --add item battery right \
               --add item clock right \
               --set battery update_freq=120 script="$PLUGIN_DIR/battery.sh" \
               --set clock update_freq=10 icon=  script="$PLUGIN_DIR/clock.sh" \
               --subscribe battery system_woke power_source_change
    sketchybar --add item volume right \
               --set volume script="$PLUGIN_DIR/volume.sh" \
               --subscribe volume volume_change \
               --set volume align="center"
    ##### Force all scripts to run the first time (never do this in a script) #####
    sketchybar --update
  '';
  
  home.file.".config/sketchybar/plugins/aerospace.sh".executable = true;
  home.file.".config/sketchybar/plugins/aerospace.sh".text = ''
    #!/usr/bin/env bash

    if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
        sketchybar --set $NAME background.drawing=on
    else
        sketchybar --set $NAME background.drawing=off
    fi
  '';
}
