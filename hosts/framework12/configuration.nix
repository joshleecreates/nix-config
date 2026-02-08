# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
      ../../modules/nixos/graphics.nix
      ../../modules/nixos/wayland.nix
      ../../modules/nixos/gaming.nix
    ];

  # Configure home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.josh = import ../../homes/josh-framework12.nix;
    users.play = import ../../homes/play-framework12.nix;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework12"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.tailscale.enable = true;

  # Enable systemd-resolved for robust DNS with caching
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    fallbackDns = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1" ];
    extraConfig = ''
      DNSOverTLS=opportunistic
    '';
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Display manager for Wayland
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "niri";

  # Video drivers (no X11 server needed - Niri uses pure Wayland + xwayland-satellite)
  # These drivers work with KMS (Kernel Mode Setting) for both Wayland and XWayland
  services.xserver.videoDrivers = [ "modesetting" ];  # Modern KMS-based driver for Intel

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    # Alt/Win swap handled by Kanata
    options = "";
  };

  # Kanata keyboard remapper
  services.kanata = {
    enable = true;
    keyboards.default = {
      config = builtins.readFile ./kanata.kbd;
      extraDefCfg = "process-unmapped-keys yes";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable polkit for niri
  security.polkit.enable = true;

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable Google OS Login
  security.googleOsLogin.enable = true;

  # Enable gnome-keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  # Enable gvfs for file manager SMB/network share support
  services.gvfs.enable = true;

  # Network discovery for SMB shares
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # Enable mDNS resolution in NSS
    openFirewall = true;
  };

  # Windows network discovery (WS-Discovery)
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Enable Wayland module (handles PipeWire, XDG portals, swaylock PAM)
  modules.wayland.enable = true;
  modules.wayland.compositor = "niri";

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;  # Enable experimental features for better LE support
      KernelExperimental = true;  # Enable kernel experimental features
      FastConnectable = true;
      Privacy = "device";  # Use device privacy mode for better compatibility
    };
    Policy = {
      AutoEnable = true;
    };
  };
  services.blueman.enable = true;

  # Enable thermald for Intel thermal management
  services.thermald.enable = true;

  # Power profiles daemon for powerprofilesctl
  services.power-profiles-daemon.enable = true;

  # UPower for battery info (required by noctalia-shell)
  services.upower.enable = true;

  # Intel-specific graphics packages (on top of base graphics module)
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver      # VAAPI driver for Intel Gen 8+ (Broadwell and newer)
    intel-compute-runtime   # OpenCL support for Intel GPUs
    vpl-gpu-rt              # Intel VPL GPU runtime (oneVPL)
  ];
  hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
    intel-media-driver      # 32-bit VAAPI support
  ];

  # Intel-specific video acceleration environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";   # Use Intel iHD driver for VAAPI
    VDPAU_DRIVER = "va_gl";      # VDPAU via VAAPI
  };

  users.users.josh = {
    isNormalUser = true;
    description = "Josh Lee";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;  # Set zsh as default shell
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  users.users.play = {
    isNormalUser = true;
    description = "Play";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;  # Set zsh as default shell
  };

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.niri.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "josh" ];

  # Enable gaming module
  modules.gaming.enable = true;

  # Allow Vivaldi to use 1Password browser integration
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      vivaldi-bin
      vivaldi
      .vivaldi-wrapped
    '';
    mode = "0755";
  };

  # Enable Docker virtualization
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      ipv6 = false;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    wget
    home-manager
    tailscale
    _1password-gui
    obsidian
    dbeaver-bin

    # Niri and essential Wayland tools (wl-clipboard is in wayland module)
    # Note: mako (notifications), swww (wallpaper) replaced by noctalia-shell
    fuzzel       # Application launcher
    swaylock     # Screen locker
    swayidle     # Idle management
    playerctl    # Media player control

    # System monitoring
    smartmontools # Disk health and temperature monitoring
    lm_sensors    # Hardware monitoring (CPU temp, fan speeds, voltages)

    # Network file sharing
    cifs-utils                      # Mount SMB/CIFS shares
    kdePackages.kio-extras          # KIO plugins for SMB (Dolphin)
    kdePackages.kdenetwork-filesharing  # KDE network file sharing
  ];
  # # Early kernel module loading and Intel graphics optimizations
  # boot.initrd.kernelModules = [ "pinctrl_tigerlake" "i915" ];
  # boot.kernelParams = [
  #   "i915.enable_fbc=1"   # Enable framebuffer compression
  #   "i915.enable_psr=2"   # Enable Panel Self Refresh
  #   "i915.fastboot=1"     # Faster boot by keeping display config
  # ];
  system.stateVersion = "25.05"; # Did you read the comment?
}
