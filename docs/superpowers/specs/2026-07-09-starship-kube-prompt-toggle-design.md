# Starship kube prompt toggle — design

Date: 2026-07-09

## Problem

`toggle-kube-prompt`, defined as a `writeShellScriptBin` in `home/common/zsh.nix`,
runs `sed -i` on `~/.config/starship.toml`. Home-manager owns that path as a
symlink into the nix store. `sed -i` replaces the symlink with a regular 444
file, so the next `nixos-rebuild switch` aborts with:

```
Existing file '/home/josh/.config/starship.toml' would be clobbered
```

and `home-manager-josh.service` exits 1. The system generation still activates,
so the symptom presents as "my home config didn't apply" rather than as a rebuild
failure.

Separately, the starship settings are copy-pasted, byte-for-byte identical,
into `homes/josh-framework12.nix` and `homes/josh-draper.nix`.

## Goal

`starship.toml` is always managed by home-manager and is never written to at
runtime. The kubernetes prompt segment defaults to off and can be enabled
per-project via direnv, with a persistent global default and a per-shell toggle.

## Mechanism

Starship's `kubernetes` module accepts `detect_env_vars`. The module renders only
when a listed variable is set in the environment, and renders nothing when it is
unset. This was verified against starship 1.25.1, the version in use:

- `detect_env_vars = ["KUBE_PROMPT"]` with `KUBE_PROMPT` unset renders nothing.
- The same config with `KUBE_PROMPT=1` renders the context.
- Starship treats an *empty* value (`KUBE_PROMPT=`) as **set**. The toggle must
  therefore `unset` the variable rather than assign `""`.
- A deliberately bogus key produced an `Unknown key` warning, confirming that the
  absence of a warning on `detect_env_vars` is a real schema match rather than
  silent tolerance of unknown keys.

Gating on an environment variable moves all mutable state out of `starship.toml`.
The file becomes a pure store artifact that nothing writes to.

## Design

### New module: `modules/home-manager/starship.nix`

Follows the `modules.<name>.enable` pattern used by the other home-manager
modules in this repo. Option `modules.starship.enable`, `types.bool`, default
`false`. The whole `config` block is guarded by `mkIf cfg.enable`.

It owns three things.

**1. Starship settings.** `programs.starship.enable`, `enableZshIntegration`, and
`settings` — the rose-pine palette, format string, and per-module styling, lifted
verbatim from the two host files. The sole edit is to the `kubernetes` block,
which gains `detect_env_vars = [ "KUBE_PROMPT" ]`:

```nix
kubernetes = {
  disabled = false;
  detect_env_vars = [ "KUBE_PROMPT" ];
  style = "bold pine";
  format = "[$symbol$context( \\($namespace\\))]($style) ";
};
```

`disabled = false` stays. `detect_env_vars` is the gate; `disabled = true` would
hide the segment unconditionally and defeat the toggle.

**2. Seed logic**, contributed to `programs.zsh.initContent` (which is
`types.lines`, so it merges with the existing block in `home/common/zsh.nix`).
At shell start, read the state file; if it contains exactly `on`, export
`KUBE_PROMPT=1`. Any other outcome — file missing, unreadable, or holding
anything else — leaves the variable unset, which is the default-off behavior.

**3. The `toggle-kube-prompt` zsh function**, replacing the `writeShellScriptBin`.
It flips `KUBE_PROMPT` in the current shell *and* writes `on` or `off` to the
state file, so the change is both immediate and persistent for new shells.
It tests set-ness with `${KUBE_PROMPT+x}`, not `-n`, matching starship's
semantics, and it `unset`s rather than assigning `""`.

### State file

Path: `$XDG_STATE_HOME/kube-prompt` (via `config.xdg.stateHome` in Nix,
`${XDG_STATE_HOME:-$HOME/.local/state}` in shell). Contents: the literal string
`on` or `off`.

Home-manager does not manage this path. The toggle owns it outright, so writing
to it can never trigger a clobber error.

### Files changed

| File | Change |
|---|---|
| `modules/home-manager/starship.nix` | new — settings, seed logic, toggle function |
| `home/home.nix` | import the new module |
| `home/common/zsh.nix` | delete the `toggle-kube-prompt` derivation and its `home.packages` entry |
| `homes/josh-framework12.nix` | delete the `programs.starship` block; add `modules.starship.enable = true;` |
| `homes/josh-draper.nix` | delete the `programs.starship` block; add `modules.starship.enable = true;` |

The module is imported in `home/home.nix` but left disabled by default, so hosts
that still use the oh-my-zsh prompt are unaffected. The two starship hosts opt in
explicitly.

`programs.zsh.oh-my-zsh.theme = lib.mkForce "";` stays in both host files. Those
hosts still want oh-my-zsh's plugins (`aws`, `git`, `kubectl`, `vi-mode`,
`docker`), just not its theme. Switching `modules.zsh.prompt` to `"starship"`
would disable oh-my-zsh entirely and lose the plugins, so it is out of scope.

## Behavior

**Default.** Segment off. No state file, no `KUBE_PROMPT`.

**Global default.** `toggle-kube-prompt` writes `on` to the state file. The
current shell picks it up immediately; new shells pick it up at init. Already-open
shells keep their existing value until toggled themselves.

**Per-project.** `export KUBE_PROMPT=1` in a project's `.envrc` turns the segment
on inside that directory. direnv unsets it on exit. To force it *off* in a project
whose global default is `on`, `.envrc` uses `unset KUBE_PROMPT`; direnv restores
the prior value on exit. direnv with zsh integration is already enabled in
`home/home.nix`.

**Known caveat.** Running `toggle-kube-prompt` inside a direnv-managed directory
whose `.envrc` touches `KUBE_PROMPT` means direnv restores its own value when you
`cd` out. The state file is still written, so new shells honor the toggle, but the
current shell's variable reverts. This is inherent to direnv's snapshot/restore
model and is accepted, not worked around.

## Error handling

Missing state file, unreadable state file, or unrecognized contents all resolve to
off. The seed logic never fails a shell startup. The toggle function creates the
state directory if absent.

## Migration

On this machine `~/.config/starship.toml` is currently a clean store symlink, so
no cleanup is needed. On any machine where the old `sed -i` toggle has run, the
path will be a regular 444 file and the first switch after this change will fail
with the clobber error. Fix: `rm ~/.config/starship.toml`, then re-run the switch.
The only state lost is whether the kube prompt was toggled off.

## Verification

1. `nixos-rebuild build --flake .#framework12` succeeds.
2. `home-manager build --flake .#josh@draper` succeeds.
3. With `KUBE_PROMPT` unset, `starship module kubernetes` prints nothing.
4. With `KUBE_PROMPT=1`, `starship module kubernetes` prints the context.
5. After running `toggle-kube-prompt`, `ls -l ~/.config/starship.toml` still shows
   a symlink into `/nix/store`.
6. Running `toggle-kube-prompt` twice flips the state file `off` → `on` → `off`
   (or the reverse) and returns the shell to its original state.
7. A switch run immediately after a toggle completes without a clobber error.
