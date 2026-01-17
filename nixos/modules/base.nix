{ pkgs, ... }:

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
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=7day
  '';

  systemd.defaultUnit = "multi-user.target";

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "/home/crazy/homelab";
  };
}
