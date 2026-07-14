# nix-config

Multi-machine NixOS, nix-darwin, and standalone home-manager configuration, managed
with flakes. It drives four NixOS systems (`framework12`, `kasti`, `workstation`,
`nixos-desktop`), one macOS system (`sting`), and three standalone home-manager
profiles (`josh@pop-os`, `josh@framework12`, `josh@silver`).

The Framework 12 laptop (`framework12`) is the primary, most-customized target: Niri
on Wayland, noctalia-shell, and the custom tooling described below.

---

## Custom desktop apps

Several launcher entries are declared as home-manager modules rather than installed as
off-the-shelf `.desktop` files. Each module follows the same shape: an
`options.modules.<name>.enable` flag, a script installed under `~/.local/bin`, and an
`xdg.desktopEntries.<name>` block so the app shows up in the noctalia launcher (and any
other desktop menu). They live in `modules/home-manager/` and are wired up in
`home/desktop.nix`.

### PKB Daily Note — `modules/home-manager/pkb-daily.nix`

Opens today's Obsidian daily note from the **PKB** vault in Neovim, inside a fresh
Ghostty window. Meant to be launched from noctalia.

- Script: `modules/home-manager/scripts/pkb-daily.sh`.
- Resolves today's note at `~/Documents/Obsidian/PKB/04 Periodic/Daily/YYYY-MM-DD.md`.
- If the note doesn't exist yet, it is seeded from the vault's Obsidian template
  (`00 Meta/Templates/Daily.md`), substituting the `{{date:…}}` placeholders for the
  ISO week link (e.g. `2026-W29`) and the long title (e.g. `Tuesday, July 14, 2026`),
  so the file matches what Obsidian itself would generate.
- Launches `ghostty --working-directory=<vault> -e nvim <note>`, rooting the window in
  the vault so wikilinks and `gf` resolve.
- Enabled via `modules.pkb-daily.enable` (on by default in `home/desktop.nix`).

Neovim itself is configured with **obsidian.nvim** (see `modules/home-manager/neovim.nix`)
so `gf` follows `[[wikilinks]]` and markdown links within the vault, with `nvim-cmp`
completion for link names and tags.

### Obsidian Daily Note — `modules/home-manager/obsidian-daily.nix`

The GUI counterpart: opens today's daily note in the **Obsidian desktop app** in a new
window. Targets the `Altinity` vault (`~/Documents/Obsidian/Altinity`), creating the
note if needed, then launches it via an `obsidian://open?...&newpane=true` URI.

- Script: `modules/home-manager/scripts/obsidian-daily.sh`.
- Enabled via `modules.obsidian-daily.enable` (on by default).

### PrusaSlicer — `modules/home-manager/prusa.nix`

Installs `prusa-slicer` and declares a desktop entry that registers the
`x-scheme-handler/prusaslicer` MIME type, so OAuth callbacks and other
`prusaslicer://` URLs open the slicer. `exec = "prusa-slicer %u"` passes the callback
URL through. Enabled via `modules.prusa.enable`.

---

## How the NixOS 1Password override works

1Password on NixOS needs two things to talk to browsers securely: a **privileged
helper** (guarded by polkit) and a **browser allowlist** the desktop app trusts for
native messaging. Both are configured on the system side; browser modules only opt in
to the client-side glue.

### System side — `hosts/framework12/homes.nix`

```nix
programs._1password.enable = true;
programs._1password-gui.enable = true;
programs._1password-gui.polkitPolicyOwners = [ "josh" ];
```

- `_1password` installs the CLI; `_1password-gui` installs the desktop app and its
  setuid `1Password-BrowserSupport` / polkit helper.
- `polkitPolicyOwners = [ "josh" ]` authorizes the `josh` user to use the browser-support
  helper and system-authentication (e.g. unlock with the login password / biometrics)
  without a root prompt.

The important **override** is the browser allowlist. By default 1Password only trusts a
fixed set of official browser binaries. On NixOS, browsers run as *wrapped* binaries
(`.vivaldi-wrapped`, `.zen-wrapped`, etc.) whose names don't match that list, so
integration silently fails. We override the trusted set by writing
`/etc/1password/custom_allowed_browsers`:

```nix
environment.etc."1password/custom_allowed_browsers" = {
  text = ''
    vivaldi-bin
    vivaldi
    .vivaldi-wrapped
    chromium
    .chromium-wrapped
    zen
    .zen-wrapped
  '';
  mode = "0755";
};
```

Every browser that should reach the desktop app — including the Nix-wrapped binary
name — must be listed here. **Adding a new browser means adding its (possibly
`.*-wrapped`) binary name to this file.**

### Browser side — native messaging manifests

The allowlist lets the desktop app *accept* a connection; the browser also needs the
native-messaging manifest that points it at 1Password. How that manifest gets created
differs by browser family:

- **Firefox-family (Firefox, Zen):** declared in Nix.
  `modules/home-manager/firefox.nix` sets
  `nativeMessagingHosts = [ pkgs._1password-gui ]` when
  `modules.firefox.onePasswordIntegration = true`, and also disables Firefox's built-in
  password manager so 1Password owns autofill. Zen does the same through `wrapFirefox`
  with `nativeMessagingHosts = [ pkgs._1password-gui ]` (see
  `modules/home-manager/zen-browser.nix`), plus a policy that installs the 1Password
  extension.
- **Chromium-family (Vivaldi, Chromium):** the desktop app writes the manifest itself
  the first time it runs, so `modules/home-manager/vivaldi.nix` deliberately does *not*
  create one. Its `onePasswordIntegration` flag is a no-op marker — all it really needs
  is `vivaldi-bin` in `custom_allowed_browsers` above.

So the two-part recipe for a **new browser**:

1. Add its binary name(s) to `custom_allowed_browsers` in
   `hosts/framework12/homes.nix`.
2. Give it the native-messaging manifest — via `nativeMessagingHosts`/`wrapFirefox` for
   Firefox-family, or nothing for Chromium-family (the app self-registers).

---

## Common commands

### NixOS (integrated with home-manager)

```bash
sudo nixos-rebuild switch --flake .#framework12    # Framework 12 (Niri + Wayland)
sudo nixos-rebuild switch --flake .#kasti
sudo nixos-rebuild switch --flake .#workstation
sudo nixos-rebuild switch --flake .#nixos-desktop
```

### Standalone home-manager

```bash
home-manager switch --flake .#josh@pop-os
home-manager switch --flake .#josh@framework12
home-manager switch --flake .#josh@silver
```

### Darwin (macOS)

```bash
darwin-rebuild switch --flake .#sting
```

### Testing changes

```bash
nixos-rebuild build --flake .#framework12   # build without switching
nix flake check                             # evaluate all outputs
nix flake show                              # list flake outputs
nix flake update                            # update all inputs
```

> New files must be `git add`-ed before `nix flake check` / rebuild will see them —
> flakes only evaluate tracked paths.

---

## Repository layout

```
├── flake.nix                 # Entry point: defines every system/home output
├── hosts/                    # Per-machine system configs
│   ├── framework12/          # Framework 12 laptop (primary)
│   ├── macbook/              # macOS (Darwin)
│   └── {kasti,workstation,nixos-desktop}/
├── homes/                    # home-manager user profiles
├── home/                     # Shared home-manager entry points (desktop.nix, common/)
├── users/                    # NixOS user account definitions
└── modules/
    ├── home-manager/         # User-space program modules (neovim, zsh, tmux, browsers,
    │                         #   pkb-daily, obsidian-daily, prusa, …)
    ├── nixos/                # System modules (wayland, …)
    └── darwin/               # macOS-only modules (homebrew, sketchybar)
```

### Integration patterns

1. **Integrated NixOS + home-manager** (`framework12`) — system and user config deploy
   together in one `nixos-rebuild`, with `useGlobalPkgs = true`.
2. **External NixOS + embedded home** (`kasti`, `workstation`, `nixos-desktop`) — uses
   external `inputs.my-modules`; home config lives inline in the host config.
3. **Standalone home-manager** (`josh@…`) — user environment only, deployable on any
   Linux/macOS host with `home-manager switch`.

Home configs compose a common base (`home/`, `home.nix`) plus machine-specific modules,
overriding shared defaults with `lib.mkDefault`.

For deeper architectural notes and conventions, see `CLAUDE.md`.
