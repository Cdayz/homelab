{ pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "deadbeef";

  # новый дефолт 26.11; pool импортируется строго по cache-file
  boot.zfs.forceImportRoot = false;

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
