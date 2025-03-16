{ pkgs, ... }:
{
  home.packages = [
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    oh-my-zsh = {
      enable = true;
      theme = "gallifrey";
      plugins = ["kubectl" "kubectx" "git" "aws"];
    };
    shellAliases = {
      ll = "ls -l";
      ta = "tmux attach";
      n = "nvim .";
      k = "kubectl";
      tmux-left = "tmux set-option status-left-length 40";
    };
    initExtra = ''
      eval "$(zoxide init zsh)"

      # aws cli auto complete
      complete -C '${pkgs.awscli}/bin/aws_completer' aws

      DISABLE_AUTO_TITLE="true"

      # Override oh-my-zsh theme prompt
      # Original: %(!.%{%}.%{%})%m%{%} %2~ $(git_prompt_info)%{%}%B»%b
      # Modified: Removed hostname, changed git branch to yellow (similar to orange)
      
      # Override git_prompt_info to change color to yellow
      function git_prompt_info() {
        ref=$(git symbolic-ref HEAD 2> /dev/null) || return
        echo "%{$fg[yellow]%}(''${ref#refs/heads/})%{$reset_color%} "
      }
      
      # Set custom prompt
      PROMPT='%{$fg_bold[white]%}%2~ $(git_prompt_info)%{$reset_color%}%B»%b '
    '';
  };
}
