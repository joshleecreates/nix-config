- [ ] Recreate NixOS Workstation Configuration
- [x] Sketchybar dependencies
- [ ] Syncthing for Raycast/OBS/Streamdeck

{
  system.defaults = {
    # Disables macOS Video Effects system-wide
    "com.apple.CoreMediaEffects" = {
      VideoEffectsEnabled = false;
    };
  };
}

## Projects
- Set up secrets
- Use nix-vim
- Try oh-my-posh
- Try zellij
