{ pkgs, ... }:

let
  crowdsecApiHost = "127.0.0.1";
  crowdsecApiPort = 18080;

  crowdsecApiUrl = "http://${crowdsecApiHost}:${toString crowdsecApiPort}";

  bouncerName = "nucbox-firewall-bouncer";
  bouncerStateDir = "/var/lib/crowdsec-firewall-bouncer";
  bouncerApiKeyFile = "${bouncerStateDir}/api-key";

  initFirewallBouncer = pkgs.writeShellScript "init-crowdsec-firewall-bouncer" ''
    set -eu

    if [ ! -s ${bouncerApiKeyFile} ]; then
      /run/current-system/sw/bin/cscli bouncers delete ${bouncerName} || true
      /run/current-system/sw/bin/cscli bouncers add ${bouncerName} --output raw > ${bouncerApiKeyFile}
    fi

    chmod 0600 ${bouncerApiKeyFile}
  '';
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

      general = {
        api.server = {
          enable = true;
          listen_uri = "${crowdsecApiHost}:${toString crowdsecApiPort}";
        };

        prometheus = {
          enabled = true;
          listen_addr = "127.0.0.1";
          listen_port = 6060;
        };
      };
    };

    localConfig.postOverflows.s01Whitelist = [
      {
        name = "homelab/trusted-networks";
        description = "Whitelist trusted homelab networks";

        whitelist = {
          reason = "trusted homelab networks";

          cidr = [
            "127.0.0.0/8"
            "192.168.0.0/16"
            "10.0.0.0/8"
            "172.16.0.0/12"
          ];
        };
      }
    ];

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

  systemd.services.crowdsec-firewall-bouncer-init = {
    description = "Initialize CrowdSec firewall bouncer API key";

    before = [ "crowdsec-firewall-bouncer.service" ];
    requiredBy = [ "crowdsec-firewall-bouncer.service" ];

    after = [ "crowdsec.service" ];
    requires = [ "crowdsec.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "crowdsec";
      Group = "crowdsec";
      StateDirectory = "crowdsec-firewall-bouncer";
      ExecStart = initFirewallBouncer;
      RemainAfterExit = true;
    };
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;
    createRulesets = true;

    registerBouncer.enable = false;
    secrets.apiKeyPath = bouncerApiKeyFile;

    settings = {
      api_url = crowdsecApiUrl;
      mode = "iptables";

      iptables_chains = [ "nixos-fw" ];

      update_frequency = "10s";
      log_mode = "stdout";
      log_level = "info";

      deny_action = "DROP";
      deny_log = false;
    };
  };

  systemd.services.crowdsec-firewall-bouncer = {
    after = [
      "firewall.service"
      "crowdsec.service"
      "crowdsec-firewall-bouncer-init.service"
    ];

    requires = [
      "crowdsec-firewall-bouncer-init.service"
    ];
  };
}
