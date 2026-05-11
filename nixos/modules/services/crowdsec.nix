{ ... }:

let
  crowdsecApiHost = "127.0.0.1";
  crowdsecApiPort = 18080;
in
{

  systemd.tmpfiles.rules = [
    "d /var/lib/crowdsec 0750 crowdsec crowdsec -"
  ];

  services.crowdsec = {
    enable = true;
    autoUpdateService = true;
    name = "nucbox";

    settings = {
      lapi.credentialsFile = "/var/lib/crowdsec/local_api_credentials.yaml";

      general.api.server = {
        enable = true;
        listen_uri = "${crowdsecApiHost}:${toString crowdsecApiPort}";
      };
    };

    localConfig.acquisitions = [
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels.type = "syslog";
      }

      {
        source = "file";
        filenames = [ "/var/log/caddy/access.log" ];
        labels.type = "caddy";
      }
    ];

    hub.collections = [
      "crowdsecurity/linux"
      "crowdsecurity/sshd"
      "crowdsecurity/caddy"
      "crowdsecurity/http-cve"
      "crowdsecurity/base-http-scenarios"
    ];
  };
}
