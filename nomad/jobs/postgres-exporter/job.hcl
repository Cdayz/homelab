job "postgres-exporter" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "app" {
    task "postgres-exporter" {
      driver = "docker"

      config {
        image        = "quay.io/prometheuscommunity/postgres-exporter:v0.19.1"
        network_mode = "host"

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}:/run/pg-exporter-secrets:ro",
        ]

        args = [
          "--web.listen-address=127.0.0.1:19187",
        ]
      }

      env {
        DATA_SOURCE_URI       = "127.0.0.1:15432/postgres?sslmode=disable"
        DATA_SOURCE_USER      = "postgres_exporter"
        DATA_SOURCE_PASS_FILE = "/run/pg-exporter-secrets/postgres_password"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}