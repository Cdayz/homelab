{ pkgs, ... }:

{
  services.caddy = {
    enable = true;

    virtualHosts."cdayz.ru".extraConfig = ''
      respond "Hello, world!"
    '';
  };
}
