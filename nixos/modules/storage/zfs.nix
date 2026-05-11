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
}
