# Kanshi + Niri Debugging Notes

## Problem Statement
- **Issue**: When laptop lid is closed, kanshi correctly switches to external-only display
- **Bug**: When switching to a different niri workspace, the laptop display reactivates
- **Already done**: Removed explicit output configurations from Niri config

## Current Configuration Analysis

### Kanshi Setup (modules/home-manager/kanshi.nix)
- 3 profiles configured:
  1. `laptop-and-external` - Both displays active
  2. `laptop-only` - Internal display only
  3. `external-only` - Samsung external only, BOE laptop display disabled

### Niri Setup (modules/home-manager/niri-config.kdl)
- No output blocks (correctly delegated to kanshi)
- Has monitor focus keybindings (Mod+Shift+H/J/K/L, etc.)
- Has workspace navigation keybindings

## Research Findings

### Known Issue: Race Condition (GitHub #676)
There's a documented race condition between niri and kanshi when outputs change:
- **Problem**: When kanshi tries to disable internal display while external display state is changing, niri can ignore the configuration
- **Root cause**: Synchronization issue - niri reports "request from an outdated configuration" when rapid changes occur
- **Key behavior**: Niri defaults to "attempt to turn on all connected monitors using their preferred modes"

### Workspace Behavior
- Each monitor has independent workspaces arranged vertically
- Workspaces **remember** their original monitor
- When a monitor disconnects, workspaces move to another monitor but remember the original
- When the monitor reconnects, workspaces automatically move back to it
- **Implication**: Even with display disabled, workspaces may be triggering re-enablement when they try to "move back" to their remembered monitor

### Updated Hypothesis
The laptop display is reactivating because:
1. Niri's default behavior is to enable all connected monitors
2. Race condition: kanshi disables display → niri detects it as still connected → niri re-enables it
3. Workspaces that "remember" the laptop monitor may be triggering display queries that wake it
4. Lid events might be sending display connect/reconnect signals that trigger niri's auto-enable behavior

## Debug Steps

### Step 1: Check niri output configuration at runtime
```bash
niri msg outputs
```

### Step 2: Monitor kanshi behavior
```bash
journalctl --user -u kanshi.service -f
```

### Step 3: Check if workspace bindings trigger display changes
- Close lid (should switch to external-only)
- Switch workspace with Mod+1, Mod+2, etc.
- Observe if laptop display reactivates

## Potential Solutions

### Solution 1: Add explicit output config in Niri (Prevent auto-enable)
Add to niri config to explicitly disable laptop display by default:
```kdl
output "BOE NV122WUM-N42" {
    off
}
```
This prevents niri's default "enable all monitors" behavior.
**Risk**: May conflict with kanshi's dual-display profile.

### Solution 2: Manual IPC workaround (from GitHub #676)
```bash
# Kill kanshi
systemctl --user stop kanshi

# Manually configure via niri IPC
niri msg output eDP-1 off
niri msg output HDMI-A-1 on

# Restart kanshi
systemctl --user start kanshi
```

### Solution 3: Use systemd-logind HandleLidSwitch
Configure logind to not suspend/handle lid, let kanshi manage displays:
```nix
services.logind.lidSwitch = "ignore";
services.logind.lidSwitchDocked = "ignore";
```

### Solution 4: Delay kanshi activation
Add delay to kanshi systemd service to let niri stabilize first:
```nix
systemd.user.services.kanshi.Service.ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
```

### Solution 5: Try wlr-randr instead of kanshi
Use wlr-randr with systemd units triggered by lid events instead of kanshi's automatic detection.

## Testing Log
- [x] Current behavior reproduced - display reactivates even without workspace switching
- [x] Checked niri outputs - confirmed eDP-1 (laptop) and DP-1 (external)
- [ ] Checked kanshi logs during workspace switch
- [ ] Tested workspace-specific settings in niri

## Changes Made

### 2025-11-26 - Attempt 1: Added explicit output disable in Niri config (FAILED)
- **File**: `modules/home-manager/niri-config.kdl:14-16`
- **Change**: Added `output "eDP-1" { off }` block
- **Result**: ❌ Fixed clamshell mode BUT broke dual-display
- **Issue**: Niri's static config overrides kanshi's dynamic configuration
- **Proof**: Kanshi logs showed "applied laptop-and-external" but `niri msg outputs` showed eDP-1 still disabled

### 2025-11-26 - Attempt 2: Configure logind to ignore lid (FAILED)
**Changes**: Added `services.logind.lidSwitch = "ignore"`
**Result**: ❌ Broke clamshell mode completely
**Issue**: Kanshi never saw "external-only" profile activation because:
  - Logind wasn't sending lid state changes
  - Kanshi only sees output connection state, not lid state
  - With both outputs "connected", kanshi kept applying "laptop-and-external"

### 2025-11-26 - Attempt 3: Custom lid handler service (TESTING)
**Files changed**:
1. Created `modules/home-manager/niri-lid-handler.nix` - New systemd service
2. `homes/josh-framework12.nix:25,35` - Import and enable lid handler
3. `hosts/framework12/configuration.nix:151-157` - Removed logind ignore settings

**How it works**:
1. Systemd service monitors `/proc/acpi/button/lid/LID0/state` every second
2. When lid closes: runs `niri msg output eDP-1 off`
3. When lid opens: runs `niri msg output eDP-1 on`
4. Kanshi detects the output state change and applies appropriate profile

**Rationale**:
- Direct control: explicitly manage display state based on physical lid position
- Separation of concerns: lid-handler → niri → kanshi (clean chain)
- Works around race condition by making lid state changes explicit
- No reliance on logind or niri's auto-enable behavior

**Expected behavior**:
- ✓ Dual-display works (lid open → service enables eDP-1 → kanshi sees both outputs)
- ✓ Clamshell mode works (lid closed → service disables eDP-1 → kanshi applies external-only)
- ✓ No workspace switching issues (niri won't re-enable what's explicitly disabled)
- **Status**: Needs nixos-rebuild and testing

## Notes
- Date: 2025-11-26
- System: framework12 (NixOS 25.05)
- Niri version: (check with `niri --version`)
- Kanshi version: (check with `kanshi --version`)
