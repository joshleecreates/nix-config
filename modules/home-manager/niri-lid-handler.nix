{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.niri-lid-handler;

  # Script to monitor lid state and control niri outputs
  lidHandlerScript = pkgs.writeShellScript "niri-lid-handler" ''
    #!/usr/bin/env bash

    LID_STATE_FILE="/proc/acpi/button/lid/LID0/state"
    INTERNAL_OUTPUT="eDP-1"

    # Function to get current lid state
    get_lid_state() {
      if [ -f "$LID_STATE_FILE" ]; then
        grep -q "closed" "$LID_STATE_FILE" && echo "closed" || echo "open"
      else
        echo "unknown"
      fi
    }

    # Function to handle lid state change
    handle_lid_state() {
      local state="$1"

      if [ "$state" = "closed" ]; then
        echo "Lid closed - disabling internal display"
        ${pkgs.niri}/bin/niri msg output "$INTERNAL_OUTPUT" off
      elif [ "$state" = "open" ]; then
        echo "Lid opened - enabling internal display"
        ${pkgs.niri}/bin/niri msg output "$INTERNAL_OUTPUT" on
      fi
    }

    # Set initial state
    PREV_STATE=$(get_lid_state)
    handle_lid_state "$PREV_STATE"

    # Monitor for changes
    while true; do
      CURRENT_STATE=$(get_lid_state)

      if [ "$CURRENT_STATE" != "$PREV_STATE" ]; then
        echo "Lid state changed: $PREV_STATE -> $CURRENT_STATE"
        handle_lid_state "$CURRENT_STATE"
        PREV_STATE="$CURRENT_STATE"
      fi

      sleep 1
    done
  '';
in {
  options.modules.niri-lid-handler = {
    enable = mkEnableOption "Niri lid state handler for automatic display management";
  };

  config = mkIf cfg.enable {
    # Systemd user service to monitor lid state
    systemd.user.services.niri-lid-handler = {
      Unit = {
        Description = "Niri lid state handler";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${lidHandlerScript}";
        Restart = "always";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
