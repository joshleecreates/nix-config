{ config, pkgs, lib, ... }:

{
  systemd.user.services.waybar = {
    Unit = {
      After = lib.mkForce "graphical-session.target";
    };
    Service = {
      ExecStartPre = "${pkgs.procps}/bin/pkill -u $USER waybar || true";
      Restart = "on-failure";
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        exclusive = true;

        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        "niri/workspaces" = {
          format = "{name}";
          all-outputs = true;
        };

        "niri/window" = {
          format = "{}";
          max-length = 50;
          rewrite = {
            "(.*) — Mozilla Firefox" = " $1";
            "(.*) - Chromium" = " $1";
            "(.*) - Visual Studio Code" = " $1";
            "Alacritty" = " Terminal";
            "ghostty" = " Terminal";
          };
        };

        clock = {
          format = "{:%a %b %d  %I:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = ["" "" "" "" ""];
        };

        network = {
          format-wifi = " {essid} ({signalStrength}%)";
          format-ethernet = " {ipaddr}";
          format-disconnected = "⚠ Disconnected";
          tooltip-format = "{ifname} via {gwaddr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)  {ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "Fira Code", monospace;
          font-size: 14px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(30, 30, 46, 0.95);
          color: #cdd6f4;
      }

      #workspaces button {
          padding: 0 8px;
          background: transparent;
          color: #cdd6f4;
          border-bottom: 3px solid transparent;
      }

      #workspaces button.active {
          background: rgba(137, 180, 250, 0.2);
          border-bottom: 3px solid #89b4fa;
      }

      #workspaces button.urgent {
          background: rgba(243, 139, 168, 0.2);
          border-bottom: 3px solid #f38ba8;
      }

      #workspaces button:hover {
          background: rgba(205, 214, 244, 0.1);
      }

      #window {
          margin: 0 8px;
          padding: 0 8px;
          color: #cdd6f4;
      }

      #clock,
      #battery,
      #network,
      #pulseaudio,
      #tray {
          padding: 0 10px;
          margin: 0 3px;
          border-radius: 8px;
      }

      #battery.charging {
          color: #a6e3a1;
      }

      #battery.warning:not(.charging) {
          color: #f9e2af;
      }

      #battery.critical:not(.charging) {
          color: #f38ba8;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #network.disconnected {
          color: #f38ba8;
      }

      #pulseaudio.muted {
          color: #6c7086;
      }

      @keyframes blink {
          to {
              color: #1e1e2e;
          }
      }
    '';
  };
}
