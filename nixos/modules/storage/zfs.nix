{ pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];

  networking.hostId = "deadbeef";

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;

    frequent = 4;
    hourly = 24;
    daily = 7;
    weekly = 4;
    monthly = 3;
  };
}
