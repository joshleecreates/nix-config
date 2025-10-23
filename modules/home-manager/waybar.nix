{ config, pkgs, lib, ... }:

{
  systemd.user.services.waybar = {
    Unit = {
      After = lib.mkForce "graphical-session.target";
    };
    Service = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.procps}/bin/pkill waybar || true'";
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
        modules-right = [ "cpu" "temperature" "pulseaudio" "network" "battery" "tray" ];

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

        cpu = {
          format = " {usage}%";
          tooltip = false;
        };

        temperature = {
          thermal-zone = 2;
          format = " {temperatureC}°C";
          critical-threshold = 80;
          format-critical = " {temperatureC}°C";
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
          font-family: 'Noto Sans Mono', 'Adwaita Mono', monospace;
          font-size: 16px;
          font-weight: bold;
          min-height: 0;
      }

      @define-color bad1 rgba(240, 60, 60, 0.5);
      @define-color bad2 rgba(200, 50, 50, 0.3);

      @define-color warning1 rgba(240, 240, 60, 0.5);
      @define-color warning2 rgba(200, 200, 50, 0.3);

      @define-color bad-hover1 rgba(250, 90, 90, 0.7);
      @define-color bad-hover2 rgba(220, 70, 70, 0.5);

      @define-color warning-hover1 rgba(250, 250, 90, 0.7);
      @define-color warning-hover2 rgba(220, 220, 70, 0.5);

      @define-color full1 rgba(60, 250, 60, 0.5);
      @define-color full2 rgba(50, 200, 50, 0.3);

      @define-color full-hover1 rgba(90, 250, 90, 0.7);
      @define-color full-hover2 rgba(70, 220, 70, 0.5);

      @define-color default1 rgba(200, 220, 240, 0.5);
      @define-color default2 rgba(120, 160, 200, 0.3);

      @define-color default11 rgba(180, 210, 255, 0.45);
      @define-color default12 rgba(100, 160, 220, 0.3);
      @define-color default13 rgba(40, 80, 120, 0.2);

      @define-color default-hover1 rgba(220, 240, 255, 0.7);
      @define-color default-hover2 rgba(140, 180, 220, 0.5);

      @define-color active1 rgba(200, 255, 225, 0.6);
      @define-color active2 rgba(120, 235, 180, 0.4);
      @define-color active3 rgba(60, 120, 60, 0.3);

      @define-color active-hover1 rgba(210, 255, 235, 0.8);
      @define-color active-hover2 rgba(150, 245, 200, 0.6);
      @define-color active-hover3 rgba(80, 160, 80, 0.4);

      @define-color default-border1 rgba(0, 0, 0, 0.3);
      @define-color default-border2 rgba(255, 255, 255, 0.4);

      @define-color empty1 rgba(0, 0, 0, 0);

      @define-color text-shadow1 rgba(0, 0, 0, 0.5);
      @define-color text-shadow1-hover rgba(255, 255, 255, 0.75);

      window#waybar {
          background: linear-gradient(
              to bottom,
              rgba(110, 150, 225, 0.7) 0%,
              rgba(100, 140, 200, 0.56) 20%,
              rgba(80, 120, 170, 0.45) 80%
          ),
          linear-gradient(
              to right,
              rgba(0, 0, 0, 0) 0%,
              rgba(110, 225, 150, 0.46) 100%
          ),
          linear-gradient(
              to right,
              rgba(50, 160, 170, 0.34) 0%,
              rgba(0, 0, 0, 0) 60%
          );
          margin: 0 10px;
          padding: 0 20px;
          border-bottom: 1px solid rgba(255, 255, 255, 0.15);
          box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.5);
          color: white;
          text-shadow: 0 1px 2px @text-shadow1;
      }

      window#waybar.empty #window {
          background: rgba(0, 0, 0, 0);
          border-left: 0 solid @empty1;
          border-top: 0 solid @empty1;
          border-right: 0 solid @empty1;
          border-bottom: 0 solid @empty1;
          box-shadow:
              inset 0 0 0 @empty1,
              0 0 0 @empty1;
      }

      #workspaces button {
          padding: 0 5px;
          background: linear-gradient(
              to bottom,
              @default11 0%,
              @default12 50%,
              @default13 100%
          );
          border: none;
          border-left: 1px solid @default-border1;
          border-top: 1px solid @default-border1;
          border-right: 1px solid @default-border2;
          border-bottom: 1px solid @default-border2;
          border-radius: 4px;
          box-shadow:
              inset 0 1px 0 rgba(255, 255, 255, 0.1),
              0 1px 2px rgba(0, 0, 0, 0.2);
          margin: 0 2px;
          transition: all 0.2s cubic-bezier(0.2, 0.9, 0.4, 1);
          text-shadow: 0 1px 2px @text-shadow1;
          min-width: 15px;
          color: white;
      }

      #workspaces button.active {
          background: linear-gradient(
              to bottom,
              @active1 0%,
              @active2 50%,
              @active3 100%
          );
      }

      #workspaces button:hover {
          background: linear-gradient(
              to bottom,
              @default-hover1 0%,
              @default-hover2 100%
          );
          text-shadow: 0 0 2px @text-shadow1-hover;
      }

      #workspaces button.active:hover {
          background: linear-gradient(
              to bottom,
              @active-hover1 0%,
              @active-hover2 100%
          );
          text-shadow: 0 0 2px @text-shadow1-hover;
      }

      #clock {
          font-family: "Source Code Pro", 'Hack', "FiraCode Nerd Font", "Iosevka Nerd Font";
          font-weight: bold;
          background: rgba(30, 40, 50, 0.4);
          padding: 0 15px;
          font-weight: normal;
      }

      #battery.charging.well,
      #battery.charging.good,
      #battery.charging.warning,
      #battery.charging.critical,
      #battery.discharging.well,
      #battery.discharging.good,
      #battery.discharging.great,
      #battery.discharging.full,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #tray,
      #window {
          background: linear-gradient(
              to bottom,
              @default1 0%,
              @default2 100%
          );
          border: none;
          border-left: 1px solid @default-border1;
          border-top: 1px solid @default-border1;
          border-right: 1px solid @default-border2;
          border-bottom: 1px solid @default-border2;
          border-radius: 4px;
          padding: 0px 10px;
          margin: 1px 5px;
          color: white;
          box-shadow:
              inset 0 1px 0 rgba(255, 255, 255, 0.1),
              0 1px 2px rgba(0, 0, 0, 0.2);
          transition: all 0.2s ease;
      }

      #battery,
      #battery.charging.great,
      #battery.charging.full {
          background: linear-gradient(
              to bottom,
              @full1 0%,
              @full2 100%
          );
          border: none;
          border-left: 1px solid @default-border1;
          border-top: 1px solid @default-border1;
          border-right: 1px solid @default-border2;
          border-bottom: 1px solid @default-border2;
          border-radius: 4px;
          padding: 0px 10px;
          margin: 1px 5px;
          color: white;
          box-shadow:
              inset 0 1px 0 rgba(255, 255, 255, 0.1),
              0 1px 2px rgba(0, 0, 0, 0.2);
          transition: all 0.2s ease;
      }

      #network.disconnected {
          background: linear-gradient(
              to bottom,
              @bad1 0%,
              @bad2 100%
          );
      }

      #battery.discharging.warning {
          background: linear-gradient(
              to bottom,
              @warning1 0%,
              @warning2 100%
          );
      }

      #battery.discharging.critical {
          background: linear-gradient(
              to bottom,
              @bad1 0%,
              @bad2 100%
          );
      }

      #battery:hover, #battery.charging.full:hover, #battery.charging.great:hover {
          background: linear-gradient(
              to bottom,
              @full-hover1 0%,
              @full-hover2 100%
          );
      }

      #battery.discharging.warning:hover {
          background: linear-gradient(
              to bottom,
              @warning-hover1 0%,
              @warning-hover2 100%
          );
      }

      #battery.discharging.critical:hover, #network.disconnected:hover {
          background: linear-gradient(
              to bottom,
              @bad-hover1 0%,
              @bad-hover2 100%
          );
      }

      #clock:hover,
      #battery.charging.good:hover,
      #battery.discharging.full:hover,
      #battery.discharging.great:hover,
      #battery.charging.well:hover,
      #battery.charging.warning:hover,
      #battery.charging.critical:hover,
      #battery.discharging.good:hover,
      #battery.discharging.well:hover,
      #cpu:hover,
      #memory:hover,
      #network:hover,
      #pulseaudio:hover,
      #backlight:hover,
      #temperature:hover,
      #window:hover {
          background: linear-gradient(
              to bottom,
              @default-hover1 0%,
              @default-hover2 100%
          );
          text-shadow: 0 0 2px @text-shadow1-hover;
      }

      #tray {
          background: rgba(40, 50, 60, 0.4);
          border-left: 1px solid rgba(0, 0, 0, 0.3);
          border-right: 1px solid rgba(255, 255, 255, 0.1);
          padding: 0 10px;
          margin: 0 2px;
      }

      tooltip {
          background: linear-gradient(
              to bottom,
              rgba(200, 220, 240, 0.5) 0%,
              rgba(120, 160, 200, 0.3) 100%
          );
          border: 1px solid rgba(200, 220, 255, 0.7);
          border-radius: 4px;
          box-shadow:
              inset 0 1px 0 rgba(255, 255, 255, 0.1),
              0 1px 2px rgba(0, 0, 0, 0.2);
          color: #2a2a2a;
          font-size: 12px;
          text-shadow: 0 2px 2px @text-shadow1;
          font-family: "Noto Sans Bold", monospace;
          padding: 4px 10px;
          transition: all 0.2s cubic-bezier(0.2, 0.9, 0.4, 1);
      }
    '';
  };
}
