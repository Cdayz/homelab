{ config, pkgs, ... }:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix

    ../../modules/base
    ../../modules/storage
    ../../modules/network
    ../../modules/services
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_19;

  networking.hostName = "nucbox";
  console = {
    font = "Lat2-Terminus16";
  };

  system.stateVersion = "25.11";
}
