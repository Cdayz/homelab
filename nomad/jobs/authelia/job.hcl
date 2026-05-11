job "authelia" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "app" {

    volume "data" {
      type            = "csi"
      source          = "authelia-data"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
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
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
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
