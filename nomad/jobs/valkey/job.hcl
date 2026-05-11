job "valkey" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "valkey" {
    network {
      port "redis" {
        static       = 16379
        to           = 6379
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
        args    = ["-ec", "mkdir -p /host/valkey/data"]

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

    task "valkey" {
      driver = "docker"

      config {
        image = "docker.io/valkey/valkey:9"
        ports = ["redis"]

        command = "/bin/sh"
        args    = ["/local/start-valkey.sh"]

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/run/valkey-secrets:ro",
        ]

        mount {
          type     = "bind"
          source   = "/var/lib/nomad-volumes/valkey/data"
          target   = "/data"
          readonly = false
        }

        labels = {
          "com.hashicorp.nomad.job_name"        = "${NOMAD_JOB_NAME}"
          "com.hashicorp.nomad.task_group_name" = "${NOMAD_GROUP_NAME}"
          "com.hashicorp.nomad.task_name"       = "${NOMAD_TASK_NAME}"
          "com.hashicorp.nomad.alloc_id"        = "${NOMAD_ALLOC_ID}"
        }
      }

      template {
        destination = "local/start-valkey.sh"
        perms       = "0755"
        data        = <<EOF
        #!/bin/sh
        set - eu

        exec valkey-server \
        --appendonly yes \
        --save 60 1 \
        --requirepass "$(cat /run/valkey-secrets/valkey_password)"
        EOF
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
