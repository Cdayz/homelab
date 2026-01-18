{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/secrets
    ../../modules/system
    ../../modules/network
    ../../modules/services
    ../../modules/users
  ];

  networking.hostName = "nucbox";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = false;
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  system.stateVersion = "25.11";
}
