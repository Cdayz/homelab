job "valkey" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "valkey" {

    restart {
      attempts = 10
      delay    = "15s"
      interval = "5m"
      mode     = "delay"
    }

    network {
      port "redis" {
        static       = 16379
        to           = 6379
        host_network = "loopback"
      }
    }

    volume "data" {
      type            = "csi"
      source          = "valkey-data"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
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
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
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
