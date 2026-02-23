# Nix Config Reorganization Plan

## Next Up: System Templates

Create reusable templates for different machine types. Each template includes both NixOS system config and home-manager config.

### Templates Needed
- **desktop** - Full Wayland desktop (niri, display manager, bluetooth, printing, etc.)
- **workstation** - Shell-only Linux (SSH, dev tools, no GUI)
- **macos** - macOS with standalone home-manager

### Directory Structure

```
common/                    # Always-on configs (no enable flag)
├── locale.nix            # Timezone, i18n
└── nix.nix               # Flakes, experimental features

templates/                 # Machine templates (import = mostly configured)
├── desktop.nix           # Full desktop: display manager, printing, docker, etc.
└── workstation.nix       # Shell-only: SSH server, dev tools

modules/nixos/             # Feature modules (opt-in with enable flags)
├── graphics.nix          # Base graphics acceleration
├── wayland.nix           # PipeWire, XDG portals
├── gaming.nix            # Steam, gamescope
├── bluetooth.nix         # Bluetooth + blueman
└── network.nix           # NetworkManager, Tailscale, Avahi

hosts/framework12/         # Device-specific
├── intel.nix             # Intel GPU packages/env vars
└── ...
```

### Module Types

| Type | Location | Enable Flag | Example |
|------|----------|-------------|---------|
| Common | `common/` | None (always on) | locale.nix |
| Template | `templates/` | `default = true` | desktop.nix |
| Feature | `modules/nixos/` | `mkEnableOption` | gaming.nix |
| Device | `hosts/*/` | None | intel.nix |

### Template Composition
```nix
# hosts/new-laptop/configuration.nix
{
  imports = [
    ./hardware.nix
    ./homes.nix
    ../../common/locale.nix
    ../../templates/desktop.nix
  ];

  # Template options (can override defaults)
  templates.desktop.printing = false;

  # Feature modules (opt-in)
  modules.gaming.enable = true;

  networking.hostName = "new-laptop";
}
```

### Implementation Steps
- [ ] Create `common/` directory
- [ ] Extract locale config → `common/locale.nix`
- [ ] Extract nix settings → `common/nix.nix`
- [ ] Create `templates/` directory
- [ ] Create `templates/desktop.nix` (display manager, polkit, gnome-keyring, gvfs, printing, docker)
- [ ] Create `templates/workstation.nix` (SSH, basic services)
- [ ] Move bluetooth → `modules/nixos/bluetooth.nix` (feature, opt-in)
- [ ] Move network → `modules/nixos/network.nix` (feature, opt-in)
- [ ] Move Intel config → `hosts/framework12/intel.nix`
- [ ] Refactor framework12/configuration.nix to use new structure

---

## Completed

### Phase 0: Cleanup (DONE)
- [x] Deleted `hosts/macbook/`, `hosts/common.nix`, `hosts/mini.nix`, `hosts/silver.nix`
- [x] Deleted `modules/darwin/` directory
- [x] Removed `darwinConfigurations.sting` and all homebrew/darwin inputs from flake.nix
- [x] Deleted `homes/joshlee.nix` and `homes/work.nix`
- [x] Removed `nixosConfigurations.kasti`, `workstation`, `nixos-desktop` from flake.nix
- [x] Deleted `hosts/kasti/`, `hosts/workstation/`, `hosts/nixos-desktop/` directories
- [x] Removed `my-modules`, `nixos-generators`, `nur` inputs from flake.nix
- [x] Deleted deprecated modules: waybar, mako, wob, random-wallpaper

### Phase 1: Module Reorganization (DONE)
- [x] Moved kanshi.nix to `hosts/framework12/displays.nix`
- [x] Added enable flags to: alacritty.nix, sketchybar.nix, aerospace.nix
- [x] Created `modules/home-manager/README.md` documenting module categories

### Phase 2: Homes Reorganization (DONE)
- [x] Created new `homes/home.nix` (consolidated shell.nix + ops.nix)
- [x] Created new `homes/desktop.nix` (imports home.nix + GUI + wayland/niri)
- [x] Created `homes/macos.nix` (imports home.nix + aerospace, sketchybar)
- [x] Updated user files to use new structure
- [x] Deleted `homes/common/` directory
- [x] Added `josh@silver` homeConfiguration to flake.nix

### Phase 3: Hosts Reorganization (DONE)
- [x] Created `hosts/framework12/homes.nix` - extracted user definitions
- [x] Renamed `hardware-configuration.nix` to `hardware.nix`
- [x] Updated `configuration.nix` to import from new structure

---

## Final Structure

### Flake Inputs (5)
- nixpkgs, home-manager, waybar-niri-workspaces-enhanced, zen-browser, noctalia

### Flake Outputs
- `nixosConfigurations.framework12`
- `homeConfigurations.josh@pop-os` (CLI only)
- `homeConfigurations.josh@framework12` (standalone)
- `homeConfigurations.josh@silver` (macOS)

### Homes Structure
```
homes/
├── home.nix              # Base CLI (neovim, tmux, git, zsh, ops tools)
├── desktop.nix           # Linux desktop (imports home.nix + GUI + wayland)
├── macos.nix             # macOS (imports home.nix + aerospace, sketchybar)
├── josh.nix              # pop-os identity (CLI only)
├── josh-framework12.nix  # Framework 12 (desktop + framework modules)
└── play-framework12.nix  # Play user (desktop + gaming)
```

### Hosts Structure
```
hosts/
└── framework12/
    ├── configuration.nix  # System config
    ├── homes.nix          # User definitions + home-manager
    ├── hardware.nix       # Hardware config
    ├── displays.nix       # Kanshi display profiles
    ├── kanata.kbd         # Keyboard remap
    └── cachix.nix         # Binary cache
```

### Module Categories
- **Feature modules** (with enable flags): firefox, gaming, niri, aerospace, etc.
- **Config modules** (imported = enabled): git, tmux, neovim, zsh
- **Device-specific** (in hosts/): displays.nix

---

## Testing

```bash
nix flake check
nixos-rebuild build --flake .#framework12
nixos-rebuild switch --flake .#framework12
home-manager build --flake .#josh@silver
```
