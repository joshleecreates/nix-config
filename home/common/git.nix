{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Josh Lee";
        email = "josh@joshuamlee.com";
      };
      credential = {
        "https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        "https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      alias = {
        cm = "commit";
        ca = "commit --amend --no-edit";
        co = "checkout";
        cp = "cherry-pick";

        di = "diff";
        dh = "diff HEAD";

        pu = "pull";
        ps = "push";
        pf = "push --force-with-lease";

        st = "status -sb";
        fe = "fetch";
        gr = "grep -in";

        ri = "rebase -i";
        rc = "rebase --continue";
      };
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      init.defaultBranch = "main";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      core.excludesfile = "~/.gitignore";
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      pull = {
        ff = false;
        commit = false;
        rebase = true;
      };
      delta = { line-numbers = true; };
    };
    ignores = [
      # ide
      ".idea"
      ".vs"
      ".vsc"
      ".vscode"
      # npm
      "node_modules"
      "npm-debug.log"
      # python
      "__pycache__"
      "*.pyc"

      ".ipynb_checkpoints" # jupyter
      "__sapper__" # svelte
      ".DS_Store" # mac
      ".worktrees" # `wt` git worktree checkouts
    ];
  };
  
  # Open (or tear down) a GitHub PR or branch in its own herdr workspace, backed
  # by a git worktree. The worktree checkout lives in a gitignored .worktrees/
  # dir inside the repo (also excluded from Syncthing); herdr spawns a fresh
  # workspace for it, split into two stacked panes — Neovim (via the `n`
  # shortcut) on top, a shell below.
  #
  #   wt pr 1234        # check out PR #1234, tracking set up so pushes update it
  #   wt branch NAME    # open branch NAME, creating it off the default branch if new
  #   wt rm [-b]        # remove the current worktree/workspace (-b: also delete the branch)
  #   wt rm [-b] branch NAME | pr 1234   # remove a specific one
  #
  # Run from inside the repo you want a worktree of.
  programs.zsh.initContent = ''
    wt() {
      emulate -L zsh 2>/dev/null || true

      local sub="$1"; shift 2>/dev/null
      case "$sub" in
        pr|branch|rm) ;;
        *)
          echo "usage: wt <pr|branch|rm> ..." >&2
          echo "  wt pr 1234        open GitHub PR #1234 in a new worktree/workspace" >&2
          echo "  wt branch NAME    open branch NAME (creating it from the default branch if new)" >&2
          echo "  wt rm [-b]        remove the current worktree/workspace (-b: also delete branch)" >&2
          echo "  wt rm [-b] branch NAME | pr 1234   remove a specific one" >&2
          return 2 ;;
      esac

      # Must be run from inside the repo (or one of its worktrees).
      local repo
      repo=$(git rev-parse --show-toplevel) || return 1

      # ---- rm: tear down a worktree + its workspace ---------------------------
      if [[ "$sub" == rm ]]; then
        local delbranch=0
        local -a rest
        local a
        for a in "$@"; do
          case "$a" in
            -b|--branch) delbranch=1 ;;
            *) rest+=("$a") ;;
          esac
        done

        local ws branch entry
        if [[ -z "$rest[1]" ]]; then
          # No target given: act on the workspace we're currently in.
          ws="$HERDR_WORKSPACE_ID"
          if [[ -z "$ws" ]]; then
            echo "wt rm: not inside a herdr workspace; pass 'branch NAME' or 'pr N'" >&2; return 2
          fi
        else
          local kind="$rest[1]" arg="$rest[2]"
          if [[ -z "$arg" ]]; then echo "wt rm: missing argument" >&2; return 2; fi
          case "$kind" in
            pr)     branch=$(gh pr view "$arg" --json headRefName -q .headRefName) || return 1 ;;
            branch) branch="$arg" ;;
            *)      echo "wt rm: expected 'branch NAME' or 'pr N'" >&2; return 2 ;;
          esac
        fi

        # Resolve the target worktree from herdr's list (by workspace or branch).
        local list
        list=$(herdr worktree list --cwd "$repo" --json) || return 1
        if [[ -n "$ws" ]]; then
          entry=$(print -r -- "$list" | jq -c --arg ws "$ws" \
            '.result.worktrees[] | select(.open_workspace_id==$ws)')
        else
          entry=$(print -r -- "$list" | jq -c --arg b "$branch" \
            '.result.worktrees[] | select(.branch==$b)')
        fi

        if [[ -z "$entry" ]]; then
          echo "wt rm: no worktree found for ''${branch:-workspace $ws}" >&2; return 1
        fi
        if [[ "$(print -r -- "$entry" | jq -r '.is_linked_worktree')" != "true" ]]; then
          echo "wt rm: refusing to remove the main worktree" >&2; return 1
        fi

        local wtdir
        ws=$(print -r -- "$entry" | jq -r '.open_workspace_id')
        branch=$(print -r -- "$entry" | jq -r '.branch')
        wtdir=$(print -r -- "$entry" | jq -r '.path')

        if [[ -n "$ws" && "$ws" != null ]]; then
          herdr worktree remove --workspace "$ws" --force >/dev/null || return 1
        else
          git -C "$repo" worktree remove --force "$wtdir" || return 1
        fi
        echo "Removed worktree for '$branch'."

        if (( delbranch )); then
          git -C "$repo" branch -D "$branch" && echo "Deleted branch '$branch'."
        fi
        return
      fi

      # ---- pr / branch: open a worktree --------------------------------------
      local arg="$1"
      if [[ -z "$arg" ]]; then
        echo "wt $sub: missing argument" >&2; return 2
      fi

      # Default branch to base new branches on (e.g. main), from origin/HEAD.
      local base
      base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
      base="''${base#origin/}"
      : "''${base:=main}"

      # Resolve the subcommand down to a single local branch name.
      local branch
      case "$sub" in
        pr)
          branch=$(gh pr view "$arg" --json headRefName -q .headRefName) || {
            echo "wt pr: could not resolve PR #$arg" >&2; return 1; }
          ;;
        branch)
          branch="$arg"
          ;;
      esac

      # Open the worktree's workspace. `worktree open` reuses an existing
      # worktree for this branch; if none exists yet, `worktree create` makes it
      # under the repo's gitignored .worktrees/ dir (checking out the branch, or
      # creating it from $base when brand new).
      local json wtname="''${branch//\//-}"
      json=$(herdr worktree open --cwd "$repo" --branch "$branch" --focus --json 2>/dev/null)
      if [[ -z "$json" || "$json" == *'"error"'* ]]; then
        json=$(herdr worktree create --cwd "$repo" --branch "$branch" --base "$base" \
          --path "$repo/.worktrees/$wtname" --focus --json) || return 1
      fi

      local pane dir opened
      pane=$(print -r -- "$json" | jq -r '.result.root_pane.pane_id')
      dir=$(print -r -- "$json" | jq -r '.result.worktree.path')
      opened=$(print -r -- "$json" | jq -r '.result.already_open')

      if [[ -z "$pane" || "$pane" == null ]]; then
        echo "wt: could not determine the workspace pane" >&2; return 1
      fi

      # If the workspace was already up, just focus it (done via --focus above)
      # and leave its panes alone — nothing more to set up.
      if [[ "$opened" == "true" ]]; then
        return
      fi

      # For a PR, wire the local branch up to the PR (sets tracking so pushes
      # update the PR, and handles cross-fork PRs).
      if [[ "$sub" == pr ]]; then
        ( cd "$dir" && gh pr checkout "$arg" --force ) || true
      fi

      # Two stacked panes: shell below, Neovim in the (focused) top pane via the
      # `n` shortcut.
      herdr pane split "$pane" --direction down --cwd "$dir" --no-focus >/dev/null
      herdr pane run "$pane" "n" >/dev/null
    }
  '';

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [ "#88C0D0" "bold" ]; # nord8 frost
          inactiveBorderColor = [ "#4C566A" ]; # nord3
          optionsTextColor = [ "#81A1C1" ]; # nord9
          selectedLineBgColor = [ "#434C5E" ]; # nord2
          cherryPickedCommitBgColor = [ "#434C5E" ]; # nord2
          cherryPickedCommitFgColor = [ "#88C0D0" ]; # nord8
          markedBaseCommitBgColor = [ "#434C5E" ]; # nord2
          markedBaseCommitFgColor = [ "#EBCB8B" ]; # nord13
          unstagedChangesColor = [ "#BF616A" ]; # nord11 red
          defaultFgColor = [ "#D8DEE9" ]; # nord4
        };
      };
    };
  };
}