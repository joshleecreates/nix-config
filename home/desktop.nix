{ config, pkgs, lib, ... }:

# Linux desktop configuration - GUI apps + Wayland/Niri
# Imports home.nix for base CLI tools

{
  imports = [
    ./home.nix

    # GUI applications
    ../modules/home-manager/ghostty.nix
    ../modules/home-manager/firefox.nix
    ../modules/home-manager/vivaldi.nix
    ../modules/home-manager/thunderbird.nix
    ../modules/home-manager/zoom.nix
    ../modules/home-manager/prusa.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/obsidian-daily.nix
    ../modules/home-manager/pkb-daily.nix
    ../modules/home-manager/gaming.nix
    ../modules/home-manager/zen-browser.nix

    # Wayland / Niri
    ../modules/home-manager/niri.nix
    ../modules/home-manager/nirius.nix
    ../modules/home-manager/niri-lid-handler.nix

    # Noctalia plugins
    ../modules/home-manager/noctalia-work-mode.nix
  ];

  # Enable GUI modules
  modules.ghostty.enable = true;
  modules.firefox.enable = true;
  modules.firefox.onePasswordIntegration = true;
  modules.vivaldi.enable = true;
  modules.vivaldi.onePasswordIntegration = true;
  modules.thunderbird.enable = true;
  modules.thunderbird.onePasswordIntegration = true;
  modules.zoom.enable = true;
  modules.prusa.enable = true;
  modules.alacritty.enable = true;

  # Enable Wayland / Niri
  modules.niri.enable = true;
  modules.nirius.enable = true;
  modules.niri-lid-handler.enable = true;

  # Optional desktop features (enabled by default, can override)
  modules.obsidian-daily.enable = lib.mkDefault true;
  modules.pkb-daily.enable = lib.mkDefault true;
  modules.gaming.enable = lib.mkDefault false;
  modules.zen-browser.enable = lib.mkDefault false;

  # Noctalia shell - status bar, notifications, wallpaper
  modules.noctalia-work-mode.enable = true;
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      notifications = {
        normalUrgencyDuration = 60;
      };
      audio = {
        mprisBlacklist = [ "spotify" ];
      };
      wallpaper = {
        enabled = true;
        directory = "~/wallpapers";
      };
      # Resting color scheme (work mode off). The Work Mode bar widget switches this
      # to Nord at runtime when toggled on. Pinned here so a fresh start (work mode
      # defaults off) matches. settings.json is nix-owned, so this must live here.
      colorSchemes = {
        darkMode = true;
        useWallpaperColors = false;
        predefinedScheme = "Gruvbox";
        schedulingMode = "off";
      };
      # Bar layout is fully nix-owned (settings.json is a read-only symlink), so the
      # whole widget list must be declared. Restored from the pre-nix hand-tuned layout,
      # with the Work Mode plugin button inserted next to NotificationHistory (alerts).
      bar = {
        backgroundOpacity = 0.93;
        barType = "simple";
        capsuleOpacity = 1;
        density = "default";
        exclusive = true;
        floating = false;
        frameRadius = 12;
        frameThickness = 8;
        hideOnOverview = false;
        marginHorizontal = 4;
        marginVertical = 4;
        monitors = [ ];
        outerCorners = true;
        position = "top";
        screenOverrides = [ ];
        showCapsule = true;
        showOutline = false;
        useSeparateOpacity = false;
        widgets = {
          # Left: launcher, calendar (Clock), temperature (SystemMonitor), window, media
          left = [
            {
              id = "Launcher";
              icon = "rocket";
              usePrimaryColor = false;
            }
            {
              id = "Clock";
              customFont = "";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm - dd MM";
              tooltipFormat = "HH:mm ddd, MMM dd";
              useCustomFont = false;
              usePrimaryColor = false;
            }
            {
              id = "SystemMonitor";
              compactMode = true;
              diskPath = "/";
              showCpuTemp = true;
              showCpuUsage = true;
              showDiskUsage = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showMemoryAsPercent = false;
              showMemoryUsage = true;
              showNetworkStats = false;
              showSwapUsage = false;
              useMonospaceFont = true;
              usePrimaryColor = false;
            }
            {
              id = "ActiveWindow";
              colorizeIcons = false;
              hideMode = "hidden";
              maxWidth = 145;
              scrollingMode = "hover";
              showIcon = true;
              useFixedWidth = false;
            }
            {
              id = "MediaMini";
              compactMode = false;
              compactShowAlbumArt = true;
              compactShowVisualizer = false;
              hideMode = "hidden";
              hideWhenIdle = false;
              maxWidth = 145;
              panelShowAlbumArt = true;
              panelShowVisualizer = true;
              scrollingMode = "hover";
              showAlbumArt = true;
              showArtistFirst = true;
              showProgressRing = true;
              showVisualizer = false;
              useFixedWidth = false;
              visualizerType = "linear";
            }
          ];
          # Center: workspaces
          center = [
            {
              id = "Workspace";
              characterCount = 2;
              colorizeIcons = false;
              emptyColor = "secondary";
              enableScrollWheel = true;
              focusedColor = "primary";
              followFocusedScreen = false;
              groupedBorderOpacity = 1;
              hideUnoccupied = false;
              iconScale = 0.8;
              labelMode = "index";
              occupiedColor = "secondary";
              showApplications = false;
              showBadge = true;
              showLabelsOnlyWhenOccupied = true;
              unfocusedIconsOpacity = 1;
            }
          ];
          right = [
            {
              id = "Tray";
              blacklist = [ ];
              colorizeIcons = false;
              drawerEnabled = true;
              hidePassive = false;
              pinned = [ ];
            }
            {
              id = "NotificationHistory";
              hideWhenZero = false;
              hideWhenZeroUnread = false;
              showUnreadBadge = true;
            }
            # Work Mode toggle button, next to the alerts (NotificationHistory) icon.
            { id = "plugin:work-mode"; }
            {
              id = "Network";
              displayMode = "onhover";
            }
            {
              id = "Battery";
              deviceNativePath = "";
              displayMode = "onhover";
              hideIfIdle = false;
              hideIfNotDetected = true;
              showNoctaliaPerformance = false;
              showPowerProfiles = false;
              warningThreshold = 30;
            }
            {
              id = "Volume";
              displayMode = "onhover";
              middleClickCommand = "pwvucontrol || pavucontrol";
            }
            {
              id = "ControlCenter";
              colorizeDistroLogo = false;
              colorizeSystemIcon = "none";
              customIconPath = "";
              enableColorization = false;
              icon = "noctalia";
              useDistroLogo = false;
            }
          ];
        };
      };
    };
  };

  # Foot terminal
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
      };
      colors = {
        alpha = "0.85";
      };
    };
  };

  # App launcher handled by noctalia-shell (Mod+Space -> launcher toggle IPC)

  home.packages = with pkgs; [
    # Desktop tools
    chromium
    slack
    termius
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
    _1password-gui
    discord
    distrobox
    libheif
    unzip

    # Media
    mpv
    spotify
    spotify-player
    vlc
    davinci-resolve
    signal-desktop
    ffmpeg-full
  ];

  # MIME type associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Archives
      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/gzip" = [ "org.kde.ark.desktop" ];
      "application/x-rar" = [ "org.kde.ark.desktop" ];
      # Web
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      # Video
      "video/mp4" = [ "vlc.desktop" ];
      # App handlers
      "x-scheme-handler/slack" = [ "slack.desktop" ];
      "x-scheme-handler/sgnl" = [ "signal.desktop" ];
      "x-scheme-handler/signalcaptcha" = [ "signal.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;

  # Desktop entries
  xdg.desktopEntries = {
    termius-app = {
      name = "Termius";
      genericName = "Cross-platform SSH client";
      comment = "The SSH client that works on Desktop and Mobile";
      exec = "termius-app %u";
      icon = "termius-app";
      categories = [ "Network" ];
      mimeType = [ "x-scheme-handler/termius" ];
    };

    spotify-player = {
      name = "Spotify Player";
      comment = "Terminal Spotify client";
      exec = "foot --app-id=spotify_ui --font=monospace:size=18 spotify_player";
      icon = "spotify";
      terminal = false;
      type = "Application";
      categories = [ "Audio" "Music" "Player" ];
    };

    btop = {
      name = "btop";
      comment = "Resource monitor";
      exec = "foot --app-id=btop_ui --font=monospace:size=13 btop";
      icon = "utilities-system-monitor";
      terminal = false;
      type = "Application";
      categories = [ "System" "Monitor" ];
    };

    chatgpt = {
      name = "ChatGPT";
      comment = "ChatGPT web application";
      exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=chatgpt --name=chatgpt --app-id=chatgpt --app=https://chatgpt.com";
      icon = "chromium";
      terminal = false;
      type = "Application";
      categories = [ "Network" "WebBrowser" ];
    };

    google-meet = {
      name = "Google Meet";
      comment = "Google Meet video conferencing";
      exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=google-meet --name=google-meet --app-id=google-meet --app=https://meet.google.com";
      icon = "chromium";
      terminal = false;
      type = "Application";
      categories = [ "Network" "VideoConference" ];
    };

    google-calendar = {
      name = "Google Calendar";
      comment = "Google Calendar";
      exec = "chromium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --class=google-calendar --name=google-calendar --app-id=google-calendar --app=https://calendar.google.com";
      icon = "chromium";
      terminal = false;
      type = "Application";
      categories = [ "Network" "Calendar" "Office" ];
    };
  };
}
