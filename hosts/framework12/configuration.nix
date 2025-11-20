# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
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
  services.tailscale.enable = true;

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];  # Modern KMS-based driver for Intel
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin.enable = false;
  services.desktopManager.plasma6.enable = true;

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
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable polkit for niri
  security.polkit.enable = true;

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable gnome-keyring
  services.gnome.gnome-keyring.enable = true;

  # XDG Desktop Portal for file pickers and other desktop integrations
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
  };

  # PAM configuration for swaylock
  security.pam.services.swaylock = {};

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable thermald for Intel thermal management
  services.thermald.enable = true;

  # Enable hardware acceleration for Intel graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # For 32-bit applications
    extraPackages = with pkgs; [
      intel-media-driver  # VAAPI driver for Intel Gen 8+ (Broadwell and newer)
      intel-compute-runtime  # OpenCL support for Intel GPUs
      vpl-gpu-rt  # Intel VPL GPU runtime (oneVPL)
      mesa  # Mesa drivers including Vulkan (ANV for Intel)
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      intel-media-driver  # 32-bit VAAPI support
    ];
  };

  # System-wide video acceleration environment variables
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";  # Use Intel iHD driver for VAAPI
    VDPAU_DRIVER = "va_gl";  # VDPAU via VAAPI
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

  # Allow Vivaldi to use 1Password browser integration
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      vivaldi-bin
      vivaldi
      .vivaldi-wrapped
    '';
    mode = "0755";
  };


  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;  # GameScope compositor for Steam games
    extest.enable = false;  # DISABLED: Causes ELF class mismatch errors

    # Extra compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # GE-Proton for better game compatibility
    ];

    # Enable Wayland support with hardware acceleration
    package = pkgs.steam.override {
      extraLibraries = pkgs: with pkgs; [
        # X11 libraries (for XWayland with xwayland-satellite)
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        xorg.libxshmfence
        xorg.libXxf86vm
        xorg.libXdamage
        xorg.libXfixes
        xorg.libXrandr

        # Graphics and video acceleration libraries
        libva
        intel-media-driver
        mesa
        libGL
        libglvnd
        vulkan-loader
        vulkan-validation-layers

        # Wayland support
        libdrm
        wayland
        libxkbcommon
      ];
      extraProfile = ''
        # Force X11 backend for Steam client (for xwayland-satellite compatibility)
        # NOTE: Keep WAYLAND_DISPLAY set so xwayland-satellite can function
        export GDK_BACKEND=x11
        export QT_QPA_PLATFORM=xcb

        # UI Scaling
        export GDK_SCALE=1.25
        export GDK_DPI_SCALE=1.25

        # Hardware acceleration for Intel graphics
        export LIBVA_DRIVER_NAME=iHD

        # Mesa/DRI configuration
        export MESA_LOADER_DRIVER_OVERRIDE=iris
        export __GLX_VENDOR_LIBRARY_NAME=mesa
      '';
    };
  };

  # Enable Steam hardware support
  hardware.steam-hardware.enable = true;

  # Enable Docker virtualization
  virtualisation.docker.enable = true;

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

    # Niri and essential Wayland tools
    fuzzel       # Application launcher
    swaylock     # Screen locker
    mako         # Notification daemon
    swayidle     # Idle management
    swww         # Background manager with namespace support
    wl-clipboard # Clipboard utilities
    playerctl    # Media player control

    # Vulkan support for Steam and games
    vulkan-loader
    vulkan-tools  # Includes vulkaninfo for debugging

    # System monitoring
    smartmontools # Disk health and temperature monitoring
    lm_sensors    # Hardware monitoring (CPU temp, fan speeds, voltages)
  ];
  # Early kernel module loading and Intel graphics optimizations
  boot.initrd.kernelModules = [ "pinctrl_tigerlake" "i915" ];
  boot.kernelParams = [
    "i915.enable_fbc=1"   # Enable framebuffer compression
    "i915.enable_psr=2"   # Enable Panel Self Refresh
    "i915.fastboot=1"     # Faster boot by keeping display config
  ];
  system.stateVersion = "25.05"; # Did you read the comment?
}
