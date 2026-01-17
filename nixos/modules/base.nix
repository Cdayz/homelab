{ lib, pkgs, ... }:

{
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tmux
    curl
    wget
    age
    sops
    go-task
    fish
  ];

  programs.fish.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=7day
  '';

  systemd.defaultUnit = lib.mkForce "multi-user.target";
  systemd.services.NetworkManager.wantedBy = [ "multi-user.target" ];

  networking.useNetworkd = false;
  systemd.network.enable = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [
    "interface-name:cni0"
    "interface-name:flannel.1"
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "/home/crazy/homelab";
  };
}
