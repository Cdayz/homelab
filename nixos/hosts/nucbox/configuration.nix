{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/base.nix
    ../../modules/users.nix
    ../../modules/ssh.nix
    ../../modules/firewall.nix
    ../../modules/directories.nix
    ../../modules/k3s.nix
    ../../modules/secrets.nix
    ../../modules/argocd-bootstrap.nix
  ];

  networking.hostName = "nucbox";

  system.stateVersion = "24.11";
}
