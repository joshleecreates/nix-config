# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./homes.nix
    ../../modules/nixos/cachix.nix
    ../../modules/nixos/graphics.nix
    ../../modules/nixos/wayland.nix
    ../../modules/nixos/gaming.nix
  ];

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

  # Syncthing — runs as josh so it can read/write the home directory.
  # Peering is declared here (overrideDevices/overrideFolders = true means the
  # web UI can't durably add peers — every rebuild/restart resets to this).
  # Peers are pinned to their Tailscale IPs (+ dynamic fallback) so repos syncs
  # over the tailnet directly instead of a public relay.
  # NOTE: ~/repos contains git working trees; syncing .git across machines
  # races with git and produces sync-conflict files. Revisit (exclude .git or
  # scope the folder) if sync-conflict files start appearing.
  services.syncthing = {
    enable = true;
    user = "josh";
    group = "users";
    configDir = "/home/josh/.config/syncthing";
    dataDir = "/home/josh/.local/share/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        kasti = {
          id = "INZN3IU-ZFMNH4F-OHLVDLD-DIXCYZJ-SX5MTAD-HNA56F2-HSDBNS3-EYIEDAI";
          addresses = [ "tcp://100.122.202.21:22000" "dynamic" ];
        };
        draper = {
          id = "DREZGHY-QCPMOHH-3EQ5LS2-EMRCCP4-LZUJTS2-TA4K7WL-ONYYFDW-F42VIQ6";
          addresses = [ "tcp://100.68.102.73:22000" "dynamic" ];
        };
      };
      folders."repos" = {
        id = "repos";
        label = "repos";
        path = "/home/josh/repos";
        devices = [ "kasti" "draper" ];
      };
      folders."kube" = {
        id = "kube";
        label = "kube";
        path = "/home/josh/.kube";
        devices = [ "kasti" ];
      };
    };
  };

  # Enable SSH
  services.openssh.enable = true;

  # Enable systemd-resolved for robust DNS with caching
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      FallbackDNS = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1" ];
      DNSOverTLS = "opportunistic";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

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

  # Restart kanata when Bluetooth keyboard connects so it gets remapped
  # Uses a systemd service with a delay to ensure the device is fully registered
  systemd.services.kanata-reload-bt = {
    description = "Reload kanata for Bluetooth keyboard";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 3 && ${pkgs.kbd}/bin/setleds -caps < /dev/console && systemctl restart kanata-default.service'";
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="iClever IC-BK06 Keyboard", TAG+="systemd", ENV{SYSTEMD_WANTS}="kanata-reload-bt.service"
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable polkit for niri
  security.polkit.enable = true;

  # Enable passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

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
      # Privacy = "device";  # Disabled - was preventing device name discovery
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

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.niri.enable = true;

  # Enable gaming module
  modules.gaming.enable = true;

  # Enable Docker virtualization
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      ipv6 = false;
    };
  };

  # Ollama - local LLM inference
  services.ollama = {
    enable = true;
    # CPU-only (Intel iGPU not supported); default pkgs.ollama is the CPU build.
    # `acceleration = false` was removed in 26.05 in favor of selecting the package.
    package = pkgs.ollama;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
  ];

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
    swaylock     # Screen locker
    swayidle     # Idle management
    playerctl    # Media player control

    # System monitoring
    smartmontools # Disk health and temperature monitoring
    lm_sensors    # Hardware monitoring (CPU temp, fan speeds, voltages)

    # AI/LLM
    ollama        # CLI for ollama service

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
