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
  ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';
}
