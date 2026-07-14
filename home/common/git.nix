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
    ];
  };
  
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