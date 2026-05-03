job "authelia" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  group "app" {
    network {
      port "http" {
        static       = 19091
        to           = 9091
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
        image = "ghcr.io/authelia/authelia:4.39.19"
        ports = ["http"]

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
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE                        = "/run/authelia-secrets/storage_encryption_key"
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
