{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = ["kubectl" "kubectx" "git" "aws" "docker"];
    };
    shellAliases = {
      ll = "ls -l";
      ta = "tmux attach";
      n = "nvim .";
      k = "kubectl";
      save-background = "$HOME/.local/bin/save-background.sh";
      random-wallpaper = "$HOME/.local/bin/random-wallpaper.sh";
    };
    initContent = ''
      # aws cli auto complete
      complete -C '${pkgs.awscli}/bin/aws_completer' aws

      # minikube completion
      source <(minikube completion zsh)

      DISABLE_AUTO_TITLE="true"
    '';
  };
}
