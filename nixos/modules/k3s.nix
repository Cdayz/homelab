{ pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";

    networkManager = true;

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
