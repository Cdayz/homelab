{ pkgs, ... }:

let
  kubeconfig = "/etc/rancher/k3s/k3s.yaml";
in
{
  systemd.services.argocd-bootstrap = {
    description = "Bootstrap ArgoCD into k3s";
    after = [ "k3s.service" ];
    requires = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      Environment = "KUBECONFIG=${kubeconfig}";
      ExecStart = ''
        set -euo pipefail

        echo "Waiting for Kubernetes API..."
        until ${pkgs.kubectl}/bin/kubectl version --short; do
          sleep 5
        done

        echo "Applying ArgoCD bootstrap manifests..."
        ${pkgs.kubectl}/bin/kubectl apply \
          -k ${../../cluster/bootstrap}
      '';
    };
  };
}
