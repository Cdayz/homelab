{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/base
    ../../modules/storage
    ../../modules/network
    ../../modules/services
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nucbox";
  console = {
    font = "Lat2-Terminus16";
  };

  system.stateVersion = "25.11";
}
