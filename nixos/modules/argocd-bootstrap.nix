{ pkgs, ... }:

{
  environment.etc."homelab".source = ../../../.;

  systemd.services.argocd-bootstrap = {
    description = "Bootstrap ArgoCD into k3s";
    after = [ "k3s.service" ];
    requires = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.kubectl}/bin/kubectl apply \
          -k /etc/homelab/cluster/bootstrap
      '';
    };
  };
}
