{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/k9s.nix
    ../../modules/home-manager/k8s-prompt.nix
  ];

  modules.k8s-prompt.enable = true;

  home.packages = with pkgs; [
    # Ops
    awscli2
    kubectl
    kubectx
    kubernetes-helm
    opentofu
    ansible
    talosctl
    argocd
    minikube
    cilium-cli
  ];
}
