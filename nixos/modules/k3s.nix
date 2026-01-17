{ pkgs, ... }:

{
  systemd.services.k3s.after = [ "NetworkManager.service" ];

  services.k3s = {
    enable = true;
    role = "server";

    extraFlags = [
      "--disable=traefik"
      "--disable=servicelb"
      "--data-dir=/srv/k3s"
    ];
  };

  environment.systemPackages = with pkgs; [
    kubectl
    helm
  ];
}
