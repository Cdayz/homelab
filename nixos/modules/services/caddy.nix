{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/log/caddy 0755 caddy caddy -"
    "f /var/log/caddy/access.log 0640 caddy caddy -"
  ];

  services.caddy = {
    enable = true;

    virtualHosts."cdayz.ru".extraConfig = ''
      respond "Hello, world!"
    '';

    virtualHosts."auth.cdayz.ru".extraConfig = ''
      log {
        output file /var/log/caddy/access.log
        format json
      }

      reverse_proxy 127.0.0.1:19091
    '';

    virtualHosts."nomad.cdayz.ru".extraConfig = ''
      log {
        output file /var/log/caddy/access.log
        format json
      }

      forward_auth 127.0.0.1:19091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      reverse_proxy 127.0.0.1:4646
    '';

    virtualHosts."memos.cdayz.ru".extraConfig = ''
      log {
        output file /var/log/caddy/access.log
        format json
      }

      reverse_proxy 127.0.0.1:15230
    '';

    virtualHosts."grafana.cdayz.ru".extraConfig = ''
      log {
        output file /var/log/caddy/access.log
        format json
      }

      reverse_proxy 127.0.0.1:13000
    '';

    virtualHosts."immich.cdayz.ru".extraConfig = ''
      log {
        output file /var/log/caddy/access.log
        format json
      }

      reverse_proxy 127.0.0.1:12283
    '';

    virtualHosts."coder.cdayz.ru".extraConfig = ''
      log {
        output file /var/log/caddy/access.log
        format json
      }

      reverse_proxy 127.0.0.1:13300
    '';
  };
}
