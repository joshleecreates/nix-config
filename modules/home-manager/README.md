# Home-Manager Modules

## Module Categories

### Feature Modules (with enable flags)
These modules provide optional features and must be explicitly enabled with `modules.<name>.enable = true`.

| Module | Description |
|--------|-------------|
| `aerospace.nix` | AeroSpace tiling window manager (macOS) |
| `alacritty.nix` | Alacritty terminal emulator |
| `firefox.nix` | Firefox with privacy settings and 1Password integration |
| `framework.nix` | Framework laptop utilities (battery, power profiles) |
| `gaming.nix` | Gaming support (Steam, gamescope, gamemode) |
| `ghostty.nix` | Ghostty terminal emulator |
| `k8s-prompt.nix` | Kubernetes prompt integration |
| `moonlight.nix` | Nvidia game streaming client |
| `niri.nix` | Niri Wayland compositor |
| `niri-lid-handler.nix` | Laptop lid handling for Niri |
| `nirius.nix` | Scratchpad utility for Niri |
| `obsidian-daily.nix` | Daily notes in Obsidian |
| `prusa.nix` | Prusa 3D printing software |
| `sesh.nix` | Smart tmux session manager |
| `sketchybar.nix` | Sketchybar status bar (macOS) |
| `thunderbird.nix` | Thunderbird email with 1Password integration |
| `vivaldi.nix` | Vivaldi browser with 1Password integration |
| `zen-browser.nix` | Zen browser |
| `zoom.nix` | Zoom video conferencing |

### Config Modules (always-on when imported)
These modules configure programs without an enable flag. Importing them activates the configuration.

| Module | Description |
|--------|-------------|
| `git.nix` | Git configuration and aliases |
| `k9s.nix` | K9s Kubernetes TUI |
| `neovim.nix` | Neovim with LSP, treesitter, telescope |
| `tmux.nix` | Tmux multiplexer with vi-mode |
| `zsh.nix` | Zsh shell configuration |

## Usage Pattern

```nix
# In your home configuration:
{
  imports = [
    ../modules/home-manager/firefox.nix
    ../modules/home-manager/git.nix  # Config modules: imported = enabled
  ];

  # Feature modules: must be explicitly enabled
  modules.firefox.enable = true;
  modules.firefox.onePasswordIntegration = true;
}
```

## Module Options

Some modules have additional options beyond `enable`:

- `firefox.nix`: `onePasswordIntegration` (bool)
- `thunderbird.nix`: `onePasswordIntegration` (bool)
- `vivaldi.nix`: `onePasswordIntegration` (bool)
- `nirius.nix`: `scratchpads` (list of {appId, spawn})
