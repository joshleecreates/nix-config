{ config, ... }: {
  homebrew = {
    enable = true;
    brews = [
      # "sniffnet" # monitor network traffic
      "sketchybar"
      "helm"
      "terraform"
      "helm-docs"
    ];
    casks = [
      # utilities
      # "meetingbar" # shows upcoming meetings
      # "font-hack-nerd-font" #fors sketchy bar

      # virtualization
      # "utm" # virtual machines

      # communication
      "zoom"
      "slack"
      "discord"

      "aerospace"

      "notunes" # stop apple music from launching
      
      "arc"
      "1password" # password manager
      "spotify" # music
      "eul" # mac monitoring
      # "wireshark" # network sniffer
      "obsidian" # zettelkasten
      "firefox"
      "iterm2"
      "ghostty"
      # "amethyst"
      "visual-studio-code"
      # "docker"
      # "spacelauncher"
      # "ubersicht"
      # "syncthing"

      "raycast"
      # "cleanshot"
      # "mimestream"
      # "screenflow"
      # "tableplus"
    ];
    
    taps = map (key: builtins.replaceStrings ["homebrew-"] [""] key) (builtins.attrNames config.nix-homebrew.taps);
  };
}
