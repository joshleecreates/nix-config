{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/k9s.nix
  ];

  home.packages = with pkgs; [
    # Ops
    kubectl
    kubectx
    kubernetes-helm
    opentofu
    ansible
    talosctl
    argocd
    minikube
  ];
}
