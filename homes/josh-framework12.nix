{ config, pkgs, lib, ... }:

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../modules/home-manager/neovim.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/git.nix
    ../modules/home-manager/zsh.nix
    ../modules/home-manager/k9s.nix
    ../modules/home-manager/alacritty.nix
    ../modules/home-manager/ghostty.nix
    ../modules/home-manager/waybar.nix
    ../modules/home-manager/sesh.nix
  ];

  # Enable sesh session manager
  modules.sesh.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Development tools
    pay-respects
    git
    gh
    ranger
    nurl
    btop
    dnsutils
    wget
    gnumake
    kubectl
    kubectx
    kubernetes-helm
    opentofu
    ansible
    talosctl
    argocd
    minikube
    
    # Framework 12 specific tools
    powertop
    brightnessctl
    acpi
    
    # Desktop tools
    chromium
    slack
    ghostty
    termius
    kdePackages.dolphin
    
    # System utilities
    pavucontrol
    networkmanagerapplet
    blueman

    # Media
    mpv
    spotify
  ];

  # Session variables configured below with niri settings

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.htop.enable = true;
  programs.ssh.enable = true;

  # Firefox configuration - clean, no sponsored content
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs._1password-gui ];
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        # Disable sponsored content and recommendations
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;

        # Disable Pocket
        "extensions.pocket.enabled" = false;
        "extensions.pocket.showHome" = false;

        # Disable telemetry
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        # Disable studies
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";

        # Disable crash reports
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # Privacy improvements
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;

        # Clean new tab page
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;

        # Disable annoying features
        "browser.vpn_promo.enabled" = false;
        "browser.promo.focus.enabled" = false;
        "browser.aboutwelcome.enabled" = false;
      };
    };
  };
  
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = lib.mkDefault [ "aws" "git" "kubectl" "vi-mode" "docker" ];
      theme = lib.mkDefault "bira";
    };
    shellAliases = {
      # Battery and power management aliases for Framework laptop
      battery = "acpi -b";
      powersave = "sudo powerprofilesctl set power-saver";
      balanced = "sudo powerprofilesctl set balanced";
      performance = "sudo powerprofilesctl set performance";
    };
  };

  # Framework 12 specific services
  services.udiskie = {
    enable = true;
    automount = true;
  };

  # Power management
  services.cbatticon = {
    enable = true;
    criticalLevelPercent = 10;
    commandCriticalLevel = ''notify-send "Battery critical" "Battery level is critically low"'';
  };

  # Niri Wayland services
  services.mako.enable = true;
  services.swayidle.enable = true;

  # Polkit agent for authentication dialogs
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit.Description = "polkit-gnome-authentication-agent-1";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Niri configuration
  xdg.configFile."niri/config.kdl".source = ../modules/home-manager/niri-config.kdl;

  # Niri-specific environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    T_REPOS_DIR = "$HOME/repos";
    NIXOS_OZONE_WL = "1";  # Enable Wayland support for Electron apps
  };
}
