job "memos" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "app" {
    restart {
      attempts = 10
      delay    = "15s"
      interval = "5m"
      mode     = "delay"
    }

    volume "data" {
      type            = "csi"
      source          = "memos-data"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "memos" {
      driver = "docker"

      config {
        image        = "neosmemo/memos:stable"
        network_mode = "host"

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/run/memos-secrets:ro",
        ]
      }

      volume_mount {
        volume      = "data"
        destination = "/var/opt/memos"
        read_only   = false
      }

      env {
        MEMOS_PORT         = "15230"
        MEMOS_DRIVER       = "postgres"
        MEMOS_DATA         = "/var/opt/memos"
        MEMOS_DSN_FILE     = "/run/memos-secrets/db_dsn"
        MEMOS_INSTANCE_URL = "https://memos.cdayz.ru"
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }
  }
}