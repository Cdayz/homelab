{ ... }:

{
  services.caddy = {
    enable = true;

    virtualHosts."cdayz.ru".extraConfig = ''
      respond "Hello, world!"
    '';

    virtualHosts."auth.cdayz.ru".extraConfig = ''
      reverse_proxy 127.0.0.1:19091
    '';

    virtualHosts."nomad.cdayz.ru".extraConfig = ''
      forward_auth 127.0.0.1:19091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      reverse_proxy 127.0.0.1:4646
    '';

    virtualHosts."grafana.cdayz.ru".extraConfig = ''
      forward_auth 127.0.0.1:19091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      reverse_proxy 127.0.0.1:13000
    '';

    virtualHosts."immich.cdayz.ru".extraConfig = ''
      reverse_proxy 127.0.0.1:12283
    '';
  };
}
