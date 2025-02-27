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

      # from recomendations
      # https://x.com/steventey/status/1800203408215027757
      "raycast"
      # "cleanshot"
      # "mimestream"
      # "screenflow"
      # "tableplus"
    ];
    
    taps = map (key: builtins.replaceStrings ["homebrew-"] [""] key) (builtins.attrNames config.nix-homebrew.taps);
  };
}
