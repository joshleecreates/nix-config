{ config, pkgs, lib, ... }:

# Josh's Framework 12 configuration - full desktop + Framework-specific

{
  home.username = lib.mkDefault "josh";
  home.homeDirectory = lib.mkDefault "/home/josh";
  home.stateVersion = lib.mkDefault "25.05";

  imports = [
    ../home/desktop.nix
    ../modules/home-manager/pi.nix
    ../modules/home-manager/herdr.nix
  ];

  # Desktop feature overrides
  modules.gaming.enable = true;
  modules.pi.enable = true;
  modules.herdr.enable = true;
  modules.zen-browser.enable = true;
  # Disable oh-my-zsh theme, use Starship instead
  programs.zsh.oh-my-zsh.theme = lib.mkForce "";
  modules.starship.enable = true;
  modules.starship.hostIcon = "💻"; # laptop → framework12

  # Framework 12 uses nord instead of the rose-pine default (neovim/tmux
  # already default to nord; this covers btop and the starship prompt).
  modules.btop.theme = "nord";
  modules.starship.theme = "nord";

  home.packages = with pkgs; [
    beekeeper-studio
    bitwarden-desktop
    bitwarden-cli
    bws
    moonlight-qt
    claude-code
    owncloud-client
    vcluster
    vscode
  ];

  # Syncthing whitelist for the ~/.kube folder: sync only *.yaml cluster
  # definitions, never ~/.kube/config (a per-machine holder for the current
  # context), the credential cache, or discovery cache. First match wins, so
  # keeps are listed before the catch-all ignore.
  home.file.".kube/.stignore".text = ''
    !*.yaml
    !*/
    *
  '';

  # Syncthing ignores for ~/repos. The stub just pulls in .stignore-shared — a
  # regular file that lives inside the synced folder, so the actual patterns
  # (root-owned/churning container data dirs, node_modules, etc.) propagate to
  # every host via Syncthing itself. Edit .stignore-shared on any machine.
  home.file."repos/.stignore".text = "#include .stignore-shared\n";

  # SSH host aliases for the other machines.
  programs.ssh = {
    enable = true;
    matchBlocks = {
      draper = {
        hostname = "draper";
        user = "josh";
      };
      kasti = {
        hostname = "workstation-kasti";
        user = "josh";
      };
      pdm = {
        hostname = "192.168.11.220";
        user = "root";
        proxyJump = "josh@workstation-kasti";
      };
    };
  };

  # Remote Claude Code login helper.
  #
  # `claude login` starts an OAuth callback server on a FIXED port
  # (localhost:3118) on whatever machine runs it. On a remote host the
  # post-sign-in browser redirect can't reach that server, so we forward the
  # laptop's localhost:3118 to the remote's 3118 (-L). Sign in in THIS
  # laptop's browser and the redirect tunnels back to the remote to finish.
  #
  #   claude-login draper                 # uses the ssh host aliases above
  #   claude-login kasti
  #   claude-login josh@some.other.host   # or any ssh target
  #
  # ExitOnForwardFailure makes ssh bail loudly if 3118 is already bound
  # locally instead of silently logging in without the tunnel. The remote
  # command runs under a login shell so `claude` is on PATH.
  programs.zsh.initContent = ''
    claude-login() {
      local host="''${1:?usage: claude-login <ssh-host>  (e.g. draper, kasti, user@host)}"
      echo "Tunneling localhost:3118 -> $host:3118 for the Claude Code OAuth callback."
      echo "When the remote prints a sign-in URL, open it in THIS laptop's browser."
      ssh -t -o ExitOnForwardFailure=yes -L 3118:127.0.0.1:3118 "$host" \
        "\$SHELL -l -c 'claude login'"
    }
  '';
}
