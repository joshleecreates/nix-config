# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a multi-machine NixOS and nix-darwin configuration repository using flakes. It manages:
- 4 NixOS systems (framework12, kasti, workstation, nixos-desktop)
- 1 Darwin system (sting - macOS)
- 3 standalone home-manager configurations

## Common Commands

### NixOS Systems (Integrated with home-manager)

```bash
# Framework 12 laptop (Niri + Wayland)
sudo nixos-rebuild switch --flake .#framework12

# Other NixOS systems
sudo nixos-rebuild switch --flake .#kasti
sudo nixos-rebuild switch --flake .#workstation
sudo nixos-rebuild switch --flake .#nixos-desktop
```

### Standalone Home-Manager

```bash
# Standalone home-manager (no NixOS integration)
home-manager switch --flake .#josh@pop-os
home-manager switch --flake .#josh@framework12
home-manager switch --flake .#josh@silver
```

### Darwin (macOS)

```bash
# macOS system rebuild
darwin-rebuild switch --flake .#sting

# Update flake inputs
nix flake update
```

### Testing Changes

```bash
# Build without switching (test for errors)
nixos-rebuild build --flake .#framework12

# Check flake syntax
nix flake check

# Show flake outputs
nix flake show
```

## Architecture Overview

### Three Integration Patterns

1. **Integrated NixOS + Home-Manager** (framework12)
   - System and user config deployed together with single `nixos-rebuild`
   - home-manager embedded in system configuration
   - Uses `useGlobalPkgs = true` for package sharing

2. **External NixOS + Embedded Home** (kasti, workstation, nixos-desktop)
   - Uses external `inputs.my-modules` (not in this repo)
   - Home config embedded directly in host configuration
   - Home-manager config appears inline in `configuration.nix`

3. **Standalone Home-Manager** (josh@pop-os, josh@framework12, josh@silver)
   - User environment only, no system integration
   - Can run on any Linux/macOS system
   - Deploy with `home-manager switch`

### Directory Structure

```
├── flake.nix                    # Main entry point defining all system outputs
├── hosts/                       # System-specific NixOS/Darwin configurations
│   ├── framework12/             # Framework 12 laptop
│   │   ├── configuration.nix    # System config with embedded home-manager
│   │   ├── hardware-configuration.nix
│   │   ├── cachix.nix
│   │   └── kanata.kbd          # Keyboard remapping config
│   ├── macbook/                # macOS (Darwin)
│   │   └── configuration.nix   # Darwin system config
│   └── [kasti|workstation|nixos-desktop]/  # External module-based systems
├── homes/                      # Home-manager user configurations
│   ├── josh-framework12.nix   # Framework 12 user config
│   ├── josh.nix               # Base Linux user config
│   ├── joshlee.nix           # macOS user config
│   └── home.nix              # Common base (imported by others)
└── modules/
    ├── home-manager/         # User-space program configurations
    │   ├── neovim.nix       # Neovim with LSP, treesitter, telescope
    │   ├── zsh.nix          # Zsh with oh-my-zsh
    │   ├── tmux.nix         # Tmux with vi-mode and plugins
    │   ├── git.nix          # Git config and aliases
    │   ├── ghostty.nix      # Terminal emulator
    │   ├── waybar.nix       # Wayland status bar (framework12)
    │   ├── niri-config.kdl  # Niri window manager (framework12)
    │   ├── aerospace.nix    # macOS window manager
    │   ├── sesh.nix         # Tmux session manager (custom module)
    │   └── kubernetes/      # k9s and k8s-prompt modules
    └── darwin/
        └── homebrew.nix     # Declarative Homebrew management
```

### Home-Manager Module Composition

All home configurations follow this pattern:
1. Import `home.nix` base with common tools (git, zsh, neovim, tmux)
2. Add machine-specific modules (e.g., waybar for Wayland, aerospace for macOS)
3. Override settings using `lib.mkDefault` for flexibility

Example: `homes/josh-framework12.nix` imports common base + adds Wayland-specific modules (waybar, niri).

## Framework 12 Specifics

The framework12 host is the most customized configuration:

### Window Manager: Niri (Wayland)
- Configuration: `modules/home-manager/niri-config.kdl`
- KDL format with comprehensive keybindings
- Touchpad uses clickfinger mode (2-finger right-click, 3-finger middle-click)
- Mod key bindings for window/workspace management

### Input Handling
- Kanata keyboard remapper: `hosts/framework12/kanata.kbd`
- System service: `services.kanata.enable = true`

### Wayland Stack
- Window manager: Niri
- Status bar: Waybar
- Launcher: Fuzzel
- Lock screen: Swaylock
- Notifications: Mako
- Idle: Swayidle

### Services Started at Login
- waybar (status bar)
- nm-applet (NetworkManager)
- blueman-applet (Bluetooth)
- polkit-gnome-authentication-agent-1
- mako (notifications)
- swayidle (idle management)

## Custom Modules

### sesh.nix (Tmux Session Manager)
- Custom options module with `enable` flag
- Usage: `modules.sesh.enable = true;`
- Integrates zoxide, fzf, and sesh for smart session management

### aerospace.nix (macOS Window Manager)
- Dynamically generates TOML config from Nix
- Workspace bindings auto-generated to avoid duplication
- Integrates with Sketchybar for visual workspace indicators

## macOS/Darwin Specifics

### Homebrew Integration
- Declarative package management via `nix-homebrew`
- Taps defined in flake inputs
- Packages listed in `modules/darwin/homebrew.nix`
- Custom patch applied to homebrew-services (see `modules/darwin/homebrew-services.patch`)

### User Configuration
Darwin uses integrated home-manager:
- System config: `hosts/macbook/configuration.nix`
- User config: `homes/joshlee.nix`
- macOS-specific modules: aerospace, sketchybar

## Key Patterns

### Default Override Pattern
Shared configs use `lib.mkDefault` to allow host-level overrides:
```nix
home.username = lib.mkDefault "josh";
```

### File Reference Pattern
For non-Nix configs, use `xdg.configFile`:
```nix
xdg.configFile."niri/config.kdl".source = ../modules/home-manager/niri-config.kdl;
```

### Dynamic Config Generation
aerospace.nix generates workspace bindings programmatically:
```nix
workspaceBindings = builtins.concatStringsSep "\n" (builtins.map
  (ws: "alt-${ws} = 'workspace ${ws}'")
  workspaces);
```

## Important Configuration Files

### Neovim
- Plugin definitions: `modules/home-manager/neovim.nix`
- Lua configs: `modules/home-manager/neovim/*.lua`
- LSP: HTML and ElixirLS configured
- Full treesitter grammar support

### Zsh
- oh-my-zsh with "bira" theme (framework12)
- Plugins: aws, git, kubectl, vi-mode, docker
- Machine-specific aliases (e.g., battery management on framework12)

### Git
- Global config in `modules/home-manager/git.nix`
- Includes useful aliases and default settings

## State Versions

Each system pins its state version to prevent automatic migrations:
- framework12: NixOS 25.05, Home-Manager 25.05
- Other systems: Check individual `configuration.nix` files

When updating state versions, review release notes and update explicitly.

## Troubleshooting

### NUR (Nix User Repository)
NUR firefox extensions are currently disabled in framework12 due to build issues. The extension configuration is commented out in `homes/josh-framework12.nix`.

### Home-Manager Activation
If home-manager fails during system rebuild, check:
1. Syntax errors in home-manager modules
2. Package availability in nixpkgs unstable
3. Conflicting file conflicts (backup existing configs)

### Flake Updates
Lock file tracks all input versions. Update cautiously:
```bash
nix flake update          # Update all inputs
nix flake lock --update-input nixpkgs  # Update specific input
```
