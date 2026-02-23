{ config, pkgs, ... }:

# User and home-manager configuration for framework12

{
  # Configure home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.josh = {
      imports = [
        ../../homes/josh-framework12.nix
        ./displays.nix
      ];
    };
    users.play = {
      imports = [
        ../../homes/play-framework12.nix
        ./displays.nix
      ];
    };

    # Framework laptop settings shared by all users
    sharedModules = [{
      home.packages = with pkgs; [
        powertop
        brightnessctl
        acpi
      ];

      # Battery tray icon
      services.cbatticon = {
        enable = true;
        criticalLevelPercent = 10;
        commandCriticalLevel = ''notify-send "Battery critical" "Battery level is critically low"'';
      };

      # Power management aliases
      programs.zsh.shellAliases = {
        battery = "acpi -b";
        powersave = "sudo powerprofilesctl set power-saver";
        balanced = "sudo powerprofilesctl set balanced";
        performance = "sudo powerprofilesctl set performance";
        rebuild = "sudo nixos-rebuild switch --flake /home/josh/repos/nix-config#framework12";
      };
    }];
  };

  # System users
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Lee";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  users.users.play = {
    isNormalUser = true;
    description = "Play";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # 1Password integration
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "josh" ];

  # Allow Vivaldi to use 1Password browser integration
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      vivaldi-bin
      vivaldi
      .vivaldi-wrapped
    '';
    mode = "0755";
  };
}
