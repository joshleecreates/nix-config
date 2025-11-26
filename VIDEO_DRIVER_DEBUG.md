# Framework 12 Video Driver Debugging Plan

## Issues
1. **Steam**: Doesn't launch at all when started via fuzzel
2. **DaVinci Resolve**: No thumbnails or video previews

## Current Graphics Setup
- Framework 12 with Intel integrated graphics
- NixOS 25.05 with Niri (Wayland) + Plasma 6
- Hardware acceleration configured in `hosts/framework12/configuration.nix:126-136`
- Current drivers: intel-media-driver, intel-compute-runtime, vpl-gpu-rt, mesa

## Debugging Steps

### Phase 1: Diagnose Current State

#### 1.1 Check Graphics Hardware Detection
```bash
# Verify Intel GPU is detected
lspci | grep -i vga
lspci | grep -i display

# Check loaded kernel modules
lsmod | grep i915
lsmod | grep video

# Check DRM devices
ls -la /dev/dri/
```

#### 1.2 Test Video Acceleration
```bash
# Check VAAPI info (should show iHD driver)
vainfo

# Check Vulkan info
vulkaninfo | head -50

# Test OpenGL
glxinfo | grep -i "opengl renderer"
```

#### 1.3 Check Steam Launch Issues
```bash
# Try launching Steam from terminal to see errors
steam

# Check if Steam process starts
ps aux | grep steam

# Check journal for Steam errors
journalctl --user -xeu steam -n 100

# Check system journal
sudo journalctl -xe | grep -i steam
```

#### 1.4 Check DaVinci Resolve
```bash
# Launch from terminal to see errors
davinci-resolve

# Check for OpenCL support
clinfo

# Check journal for Resolve errors
journalctl --user -xe | grep -i resolve
```

### Phase 2: Apply Intel Graphics Optimizations

#### 2.1 Enable Early KMS and Kernel Parameters
Add to `hosts/framework12/configuration.nix`:

```nix
# After line 241, modify boot.initrd.kernelModules
boot.initrd.kernelModules = [ "pinctrl_tigerlake" "i915" ];

# Add kernel parameters for Intel graphics optimization
boot.kernelParams = [
  "i915.enable_fbc=1"        # Enable framebuffer compression
  "i915.enable_psr=2"        # Enable Panel Self Refresh
  "i915.fastboot=1"          # Faster boot by keeping display config
];
```

#### 2.2 Add System-wide Video Acceleration Variables
Add to `hosts/framework12/configuration.nix`:

```nix
# Add after hardware.graphics section (around line 136)
environment.sessionVariables = {
  LIBVA_DRIVER_NAME = "iHD";
  VDPAU_DRIVER = "va_gl";
};
```

#### 2.3 Add 32-bit Video Acceleration Libraries
Modify `hosts/framework12/configuration.nix` hardware.graphics section:

```nix
hardware.graphics = {
  enable = true;
  enable32Bit = true;
  extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
    vpl-gpu-rt
    mesa
  ];
  extraPackages32 = with pkgs.driversi686Linux; [
    intel-media-driver
    vpl-gpu-rt
  ];
};
```

#### 2.4 Ensure Modesetting Driver for X11
Add to `hosts/framework12/configuration.nix` (around line 57):

```nix
services.xserver = {
  enable = true;
  videoDrivers = [ "modesetting" ];
  # ... rest of xserver config
};
```

### Phase 3: Steam-Specific Fixes

#### 3.1 Check Steam Environment
The current config (lines 176-200) forces X11 mode with specific environment variables. Verify:
- `LIBVA_DRIVER_NAME=iHD` is set
- `VK_ICD_FILENAMES` points to Intel Vulkan driver

#### 3.2 Test Alternative Steam Launch Methods
```bash
# Try launching with different backends
GDK_BACKEND=x11 steam

# Try with debug output
STEAM_RUNTIME_VERBOSE=1 steam 2>&1 | tee steam-debug.log

# Check if it's a desktop file issue
cat ~/.local/share/applications/steam.desktop
cat /usr/share/applications/steam.desktop
```

#### 3.3 Verify Steam Dependencies
```bash
# Check if Steam libraries are accessible
ldd $(which steam)

# Check Steam runtime
ls -la ~/.local/share/Steam/ubuntu12_32/
ls -la ~/.local/share/Steam/ubuntu12_64/
```

### Phase 4: DaVinci Resolve Specific

#### 4.1 Check OpenCL/GPU Compute
DaVinci Resolve heavily relies on GPU compute:
```bash
# Verify OpenCL
clinfo | grep -A 10 "Platform Name"

# Check if intel-compute-runtime is working
ls -la /etc/OpenCL/vendors/
cat /etc/OpenCL/vendors/intel.icd
```

#### 4.2 Resolve Cache and Config
```bash
# Check Resolve cache directory
ls -la ~/.local/share/DaVinciResolve/
ls -la ~/.cache/

# Reset Resolve preferences (backup first!)
mv ~/.local/share/DaVinciResolve ~/.local/share/DaVinciResolve.bak
```

### Phase 5: Advanced Troubleshooting

#### 5.1 Check for Firmware Issues
```bash
# Intel GPU firmware
ls -la /lib/firmware/i915/

# Check dmesg for firmware errors
sudo dmesg | grep -i firmware
sudo dmesg | grep -i i915
```

#### 5.2 Test Basic OpenGL/Vulkan Apps
```bash
# Install test apps if not present
nix-shell -p glxgears vkcube

# Test OpenGL
glxgears

# Test Vulkan
vkcube
```

#### 5.3 Check Wayland vs X11 Behavior
```bash
# Force X11 session for Steam
WAYLAND_DISPLAY= steam

# Check current session type
echo $XDG_SESSION_TYPE
echo $WAYLAND_DISPLAY
```

## Rebuild Command
After making any configuration changes:
```bash
sudo nixos-rebuild switch --flake .#framework12
```

## Diagnostics Results (2025-11-15)

### ✅ Working Components
- Intel i915 kernel module loaded correctly
- VAAPI working: Intel iHD driver v25.3.4
- Vulkan working: Intel(R) Graphics (RPL-U)
- OpenCL working: Intel OpenCL Graphics
- DRM devices present: /dev/dri/card1, /dev/dri/renderD128

### ❌ Issues Found

#### Steam Issue
**Problem**: Steam processes run but no window appears
- Multiple steamwebhelper processes running in background
- Error: `libextest.so from LD_PRELOAD cannot be preloaded (wrong ELF class: ELFCLASS32)`
- Cause: `programs.steam.extest.enable = true` at line 168 in configuration.nix
- **FIX**: Disable extest - it's causing ELF class mismatch and preventing UI

#### DaVinci Resolve Issue
**Status**: Not yet tested
- Likely related to OpenCL/GPU compute
- May need additional 32-bit graphics libraries

## Next Steps Tracker

- [x] Phase 1.1: Check GPU hardware detection
- [x] Phase 1.2: Test video acceleration (vainfo, vulkaninfo)
- [x] Phase 1.3: Get Steam error logs from terminal launch
- [x] **COMPLETED**: Disabled Steam extest (ELF class mismatch)
- [x] **COMPLETED**: Removed hardcoded VK_ICD_FILENAMES (GPU process crash fix)
- [x] Phase 2: Applied all Intel graphics optimizations
- [ ] **TESTING**: Verify Steam UI now displays correctly
- [ ] Phase 1.4: Get DaVinci Resolve error logs
- [ ] Phase 4: DaVinci Resolve specific fixes

## Notes
- Framework 12 has Intel Raptor Lake-U (13th gen) GPU
- Current config has `pinctrl_tigerlake` kernel module
- Steam config forces X11 mode (necessary for stability)
- Both apps are graphics-intensive and require proper GPU acceleration

## Applied Fixes Summary (2025-11-15)
1. ✅ Disabled `programs.steam.extest.enable` - fixed ELF class mismatch
2. ✅ Removed manual `VK_ICD_FILENAMES` - fixed GPU process crashes
3. ✅ Added early i915 kernel module loading
4. ✅ Added Intel graphics kernel parameters (FBC, PSR, fastboot)
5. ✅ Added 32-bit VAAPI driver support
6. ✅ Set system-wide LIBVA_DRIVER_NAME and VDPAU_DRIVER
7. ✅ Configured modesetting video driver for X11

## Files to Monitor
- `/home/josh/repos/nix-config/hosts/framework12/configuration.nix`
- System journal: `sudo journalctl -xe`
- User journal: `journalctl --user -xe`
