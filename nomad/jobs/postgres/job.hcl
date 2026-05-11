job "postgres" {
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "db" {
    network {
      port "postgres" {
        static       = 15432
        to           = 5432
        host_network = "loopback"
      }
    }

    volume "data" {
      type            = "csi"
      source          = "postgres-data"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "postgres" {
      driver = "docker"

      config {
        image = "ghcr.io/immich-app/postgres:16-vectorchord0.4.3-pgvectors0.3.0"
        ports = ["postgres"]

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/run/postgres-secrets:ro",
        ]
      }

      volume_mount {
        volume      = "data"
        destination = "/var/lib/postgres/data"
        read_only   = false
      }

      env {
        PGDATA                 = "/var/lib/postgres/data"
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
