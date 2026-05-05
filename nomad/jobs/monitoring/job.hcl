job "monitoring" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

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

    task "prepare-grafana-secrets" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image   = "ghcr.io/ghcr-library/busybox:1.32"
        command = "/bin/sh"
        args = ["-ec", <<-EOF
            chown 472:0 /host/grafana-secrets/oidc_client_secret
            chmod 0400 /host/grafana-secrets/oidc_client_secret
          EOF
        ]

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/host/grafana-secrets:rw",
        ]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image        = "grafana/grafana:13.0.1"
        network_mode = "host"

        entrypoint = ["/bin/bash", "-c"]
        command    = "/local/start-grafana.sh"

        volumes = [
          "${JOB_REMOTE_CONFIGS_DIR}/grafana-datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml:ro",
          "${JOB_REMOTE_CONFIGS_DIR}/grafana-dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yml:ro",
          "${JOB_REMOTE_CONFIGS_DIR}/dashboards:/etc/grafana/dashboards:ro",
          "${JOB_REMOTE_SECRETS_DIR}:/run/grafana-secrets:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/monitoring/grafana"
          target   = "/var/lib/grafana"
          readonly = false
        }
      }

      template {
        destination = "local/start-grafana.sh"
        perms       = "0755"
        data        = <<EOF
        #!/bin/sh
        set -euo pipefail

        export GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET="$(cat /run/grafana-secrets/oidc_client_secret)"

        /bin/bash /run.sh
        EOF
      }

      env {
        GF_SERVER_ROOT_URL  = "https://grafana.cdayz.ru"
        GF_SERVER_HTTP_PORT = "13000"

        GF_SECURITY_ADMIN_USER     = "admin"
        GF_SECURITY_ADMIN_PASSWORD = "admin"

        GF_USERS_ALLOW_SIGN_UP     = "false"
        GF_AUTH_DISABLE_LOGIN_FORM = "true"
        GF_AUTH_BASIC_ENABLED      = "false"

        GF_AUTH_GENERIC_OAUTH_ENABLED                 = "true"
        GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP           = "true"
        GF_AUTH_GENERIC_OAUTH_USE_PKCE                = "true"
        GF_AUTH_GENERIC_OAUTH_NAME                    = "Authelia"
        GF_AUTH_GENERIC_OAUTH_ICON                    = "signin"
        GF_AUTH_GENERIC_OAUTH_CLIENT_ID               = "grafana"
        GF_AUTH_GENERIC_OAUTH_SCOPES                  = "openid profile email groups"
        GF_AUTH_GENERIC_OAUTH_EMPTY_SCOPES            = "false"
        GF_AUTH_GENERIC_OAUTH_AUTH_URL                = "https://auth.cdayz.ru/api/oidc/authorization"
        GF_AUTH_GENERIC_OAUTH_TOKEN_URL               = "https://auth.cdayz.ru/api/oidc/token"
        GF_AUTH_GENERIC_OAUTH_API_URL                 = "https://auth.cdayz.ru/api/oidc/userinfo"
        GF_AUTH_GENERIC_OAUTH_LOGIN_ATTRIBUTE_PATH    = "preferred_username"
        GF_AUTH_GENERIC_OAUTH_USERNAME_ATTRIBUTE_PATH = "preferred_username"
        GF_AUTH_GENERIC_OAUTH_ID_ATTRIBUTE_PATH       = "sub"
        GF_AUTH_GENERIC_OAUTH_NAME_ATTRIBUTE_PATH     = "name"
        GF_AUTH_GENERIC_OAUTH_EMAIL_ATTRIBUTE_PATH    = "email"
        GF_AUTH_GENERIC_OAUTH_GROUPS_ATTRIBUTE_PATH   = "groups"
        GF_AUTH_GENERIC_OAUTH_AUTH_STYLE              = "InHeader"
        GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH     = "contains(groups[*], 'admin') && 'Admin' || contains(groups[*], 'editor') && 'Editor' || 'Viewer'"
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }
  }
}
