job "postgres" {
  datacenters = ["homelab"]
  type        = "service"

  group "db" {
    network {
      port "postgres" {
        static       = 15432
        to           = 5432
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
        args    = ["-ec", "mkdir -p /host/postgres/data"]

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

    task "postgres" {
      driver = "docker"

      config {
        image = "ghcr.io/immich-app/postgres:16-vectorchord0.4.3-pgvectors0.3.0"
        ports = ["postgres"]

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/run/postgres-secrets:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/postgres/data"
          target   = "/var/lib/postgres/data"
          readonly = false
        }
      }

      env {
        POSTGRES_USER          = "postgres"
        POSTGRES_DB            = "postgres"
        POSTGRES_PASSWORD_FILE = "/run/postgres-secrets/admin_password"
      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}
