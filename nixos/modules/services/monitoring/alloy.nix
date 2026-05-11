{ ... }:

{
  environment.etc."alloy/config.alloy".text = ''
    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:13100/loki/api/v1/push"
      }
    }

    discovery.relabel "journal" {
      targets = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }

      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "hostname"
      }

      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
    }

    loki.process "systemd" {
      forward_to = [loki.write.local.receiver]

      stage.match {
        selector = "{job=\"systemd-journal\",unit=~\"sshd.service|ssh.service\"} |~ \"Failed password|Invalid user|Accepted publickey|Accepted password|authentication failure\""

        stage.regex {
          expression = ".* from (?P<source_ip>[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+).*"
        }

        stage.geoip {
          source  = "source_ip"
          db      = "/var/lib/geoip/GeoLite2-City.mmdb"
          db_type = "city"
        }

        stage.labels {
          values = {
            geoip_country_name       = "",
            geoip_country_code       = "",
            geoip_continent_name     = "",
            geoip_continent_code     = "",
            geoip_location_latitude  = "",
            geoip_location_longitude = "",
          }
        }
      }
    }

    loki.source.journal "systemd" {
      max_age       = "12h"
      forward_to    = [loki.process.systemd.receiver]
      relabel_rules = discovery.relabel.journal.rules

      labels = {
        job  = "systemd-journal",
        host = "nucbox",
      }
    }

    local.file_match "nomad_alloc_logs" {
      path_targets = [
        {
          __path__ = "/var/lib/nomad/alloc/*/alloc/logs/*.std*",
          job      = "nomad-alloc",
          host     = "nucbox",
        },
      ]

      sync_period = "10s"
    }

    discovery.relabel "nomad_alloc_logs" {
      targets = local.file_match.nomad_alloc_logs.targets

      rule {
        source_labels = ["__path__"]
        regex         = ".*/alloc/([^/]+)/alloc/logs/([^.]+)\\.(stdout|stderr)\\.[0-9]+"
        target_label  = "alloc_id"
        replacement   = "$1"
      }

      rule {
        source_labels = ["__path__"]
        regex         = ".*/alloc/([^/]+)/alloc/logs/([^.]+)\\.(stdout|stderr)\\.[0-9]+"
        target_label  = "task"
        replacement   = "$2"
      }

      rule {
        source_labels = ["__path__"]
        regex         = ".*/alloc/([^/]+)/alloc/logs/([^.]+)\\.(stdout|stderr)\\.[0-9]+"
        target_label  = "stream"
        replacement   = "$3"
      }
    }

    loki.source.file "nomad_alloc_logs" {
      targets    = discovery.relabel.nomad_alloc_logs.output
      forward_to = [loki.write.local.receiver]
    }

    local.file_match "caddy_access_logs" {
      path_targets = [
        {
          __path__ = "/var/log/caddy/access.log",
          job      = "caddy-access",
          host     = "nucbox",
        },
      ]

      sync_period = "10s"
    }

    discovery.relabel "caddy_access_logs" {
      targets = local.file_match.caddy_access_logs.targets

      rule {
        source_labels = ["__path__"]
        target_label  = "log_file"
      }
    }

    loki.process "caddy_access_logs" {
      forward_to = [loki.write.local.receiver]

      stage.json {
        expressions = {
          remote_ip = "request.remote_ip",
          host      = "request.host",
          uri       = "request.uri",
          method    = "request.method",
          status    = "status",
        }
      }

      stage.regex {
        source     = "uri"
        expression = "^(?P<uri_path>[^?]+)"
      }

      stage.geoip {
        source  = "remote_ip"
        db      = "/var/lib/geoip/GeoLite2-City.mmdb"
        db_type = "city"
      }

      stage.labels {
        values = {
          host               = "host",
          method             = "method",
          status             = "status",
          uri_path           = "uri_path",
          geoip_country_name = "",
          geoip_country_code = "",
        }
      }
    }

    loki.source.file "caddy_access_logs" {
      targets    = discovery.relabel.caddy_access_logs.output
      forward_to = [loki.process.caddy_access_logs.receiver]
    }

    loki.source.journal "crowdsec" {
      matches = "_SYSTEMD_UNIT=crowdsec.service"

      forward_to = [loki.write.local.receiver]

      labels = {
        job = "crowdsec",
      }
    }

    loki.source.journal "crowdsec_bouncer" {
      matches = "_SYSTEMD_UNIT=crowdsec-firewall-bouncer.service"

      forward_to = [loki.write.local.receiver]

      labels = {
        job = "crowdsec-firewall-bouncer",
      }
    }
  '';

  services.alloy = {
    enable = true;
    configPath = "/etc/alloy";

    extraFlags = [
      "--disable-reporting"
    ];
  };

  users.groups.alloy = { };
  users.users.alloy = {
    isSystemUser = true;
    group = "alloy";
    extraGroups = [
      "adm"
      "systemd-journal"
      "caddy"
    ];
  };
}
