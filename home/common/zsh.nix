{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh";
    shellAliases = {
      ll = "ls -l";
      ta = "tmux attach";
      n = "nvim .";
      k = "kubectl";
      save-background = "$HOME/.local/bin/save-background.sh";
      random-wallpaper = "$HOME/.local/bin/random-wallpaper.sh";
      dsa = "docker stop $(docker ps -aq)";
      dra = "docker rm $(docker ps -aq)";
    };
    initContent = ''
      # aws cli auto complete
      complete -C '${pkgs.awscli}/bin/aws_completer' aws

      # minikube completion
      source <(minikube completion zsh)

      DISABLE_AUTO_TITLE="true"
    '';

    # Expose every kubeconfig in ~/.kube/configs/ without naming them here.
    # ~/.kube/config comes first so `kubectl config use-context` and kubectx
    # write their state there rather than mutating the per-cluster files,
    # which are decrypted from sops and should stay byte-for-byte upstream.
    #
    # This deliberately does not flatten the merge back into ~/.kube/config:
    # doing so made that file both input and output, so it accumulated stale
    # contexts forever and was rewritten world-readable with private keys in
    # it on every shell start.
    envExtra = ''
      _kubeconfigs=("$HOME/.kube/config" "$HOME"/.kube/configs/*.(yaml|yml)(N))
      export KUBECONFIG="''${(j.:.)_kubeconfigs}"
      unset _kubeconfigs
    '';
  };
}
