job "monitoring" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  group "monitoring" {
    network {
      port "loki" {
        static       = 13100
        to           = 3100
        host_network = "loopback"
      }
    }

    task "prepare-data-dir" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image   = "ghcr.io/ghcr-library/busybox:1.32"
        command = "/bin/sh"
        args = ["-ec", <<-EOF
          mkdir -p /host/monitoring/prometheus
          mkdir -p /host/monitoring/loki
          mkdir -p /host/monitoring/grafana
          chmod -R 0777 /host/monitoring
        EOF
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes"
          target   = "/host"
          readonly = false
        }
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image        = "prom/prometheus:v3.11.2"
        network_mode = "host"

        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--storage.tsdb.retention.time=15d",
          "--storage.tsdb.retention.size=10GB",
          "--web.listen-address=127.0.0.1:19090",
          "--web.enable-lifecycle",
        ]

        volumes = [
          "${JOB_REMOTE_CONFIGS_DIR}/prometheus.yml:/etc/prometheus/prometheus.yml:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/monitoring/prometheus"
          target   = "/prometheus"
          readonly = false
        }
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki:3.6.10"
        ports = ["loki"]
        args  = ["-config.file=/etc/loki/loki.yml"]

        volumes = [
          "${JOB_REMOTE_CONFIGS_DIR}/loki.yml:/etc/loki/loki.yml:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/monitoring/loki"
          target   = "/loki"
          readonly = false
        }
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image        = "grafana/grafana:13.0.1"
        network_mode = "host"

        volumes = [
          "${JOB_REMOTE_CONFIGS_DIR}/grafana-datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml:ro",
          "${JOB_REMOTE_CONFIGS_DIR}/grafana-dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yml:ro",
          "${JOB_REMOTE_CONFIGS_DIR}/dashboards:/etc/grafana/dashboards:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/monitoring/grafana"
          target   = "/var/lib/grafana"
          readonly = false
        }
      }

      env {
        GF_SERVER_ROOT_URL  = "https://grafana.cdayz.ru"
        GF_SERVER_HTTP_PORT = "13000"

        GF_SECURITY_ADMIN_USER     = "admin"
        GF_SECURITY_ADMIN_PASSWORD = "admin"

        GF_USERS_ALLOW_SIGN_UP     = "false"
        GF_AUTH_DISABLE_LOGIN_FORM = "true"
        GF_AUTH_BASIC_ENABLED      = "false"

        GF_AUTH_PROXY_ENABLED         = "true"
        GF_AUTH_PROXY_WHITELIST       = "127.0.0.1"
        GF_AUTH_PROXY_HEADER_NAME     = "Remote-User"
        GF_AUTH_PROXY_HEADER_PROPERTY = "username"
        GF_AUTH_PROXY_AUTO_SIGN_UP    = "true"
        GF_AUTH_PROXY_HEADERS         = "Email:Remote-Email Name:Remote-Name"
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }
  }
}