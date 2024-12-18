{ ... }: {
  programs.git = {
    enable = true;
    delta.enable = true;
    userName = "Josh Lee";
    userEmail = "josh@joshuamlee.com";
    aliases = {
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
    extraConfig = {
      init.defaultBranch = "main";
      pull = {
        ff = false;
        commit = false;
        rebase = true;
      };
      fetch = { prune = true; };
      push.autoSetupRemote = true;
      delta = { line-numbers = true; };
    };
  };
}
