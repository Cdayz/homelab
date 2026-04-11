{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  console = {
     font = "Lat2-Terminus16";
  };

  networking.hostName = "nucbox";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.nikita = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEEcmbQUIAw2y6jWIRt1gDmflh+yV3vHT4ytyagEKIZ cdayz@MacBook-Air-Nikita.local"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  system.stateVersion = "25.11";
}