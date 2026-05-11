job "authelia" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "app" {
    task "prepare-data-dir" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image   = "ghcr.io/ghcr-library/busybox:1.32"
        command = "/bin/sh"
        args    = ["-ec", "mkdir -p /host/authelia/data"]

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

    task "authelia" {
      driver = "docker"

      config {
        image        = "ghcr.io/authelia/authelia:4.39.19"
        network_mode = "host"

        volumes = [
          "${JOB_REMOTE_CONFIGS_DIR}:/config",
          "${JOB_REMOTE_SECRETS_DIR}:/run/authelia-secrets:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/authelia/data"
          target   = "/data"
          readonly = false
        }
      }

      env {
        AUTHELIA_SESSION_SECRET_FILE                                = "/run/authelia-secrets/session_secret"
        AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE = "/run/authelia-secrets/jwt_secret"
        X_AUTHELIA_CONFIG_FILTERS                                   = "template"
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
  }
}
