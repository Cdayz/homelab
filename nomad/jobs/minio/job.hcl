job "minio" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  group "app" {
    network {
      port "s3" {
        static       = 19100
        to           = 9000
        host_network = "loopback"
      }

      port "console" {
        static       = 19101
        to           = 9001
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
        args    = ["-ec", "mkdir -p /host/minio/data"]

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

    task "minio" {
      driver = "docker"

      config {
        image = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
        ports = ["s3", "console"]

        entrypoint = ["/bin/sh"]
        args = [
          "-ec",
          <<SH
          export MINIO_ROOT_PASSWORD="$(cat /run/minio-secrets/admin_password)"

          exec minio server /data --console-address ":9001"
          SH
        ]

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/run/minio-secrets:ro",
        ]

        mount {
          type   = "bind"
          source = "/var/lib/nomad-volumes/minio/data"
          target = "/data"
        }
      }

      env {
        MINIO_ROOT_USER = "admin"

        MINIO_BROWSER_REDIRECT_URL = "https://s3adm.cdayz.ru"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}