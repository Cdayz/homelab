{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/base.nix
    ../../modules/users.nix
    ../../modules/ssh.nix
    ../../modules/wifi.nix
    ../../modules/firewall.nix
    ../../modules/fail2ban.nix
    ../../modules/power.nix
    ../../modules/directories.nix
    ../../modules/k3s.nix
    ../../modules/secrets.nix
    ../../modules/argocd-bootstrap.nix
  ];

  networking.hostName = "nucbox";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  system.stateVersion = "25.11";
}
