{ ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "processes"
      "diskstats"
      "filesystem"
      "netstat"
      "hwmon"
    ];
    port = 9100;
    listenAddress = "127.0.0.1";
  };

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

    loki.source.journal "systemd" {
      max_age       = "12h"
      forward_to    = [loki.write.local.receiver]
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
    ];
  };
}
