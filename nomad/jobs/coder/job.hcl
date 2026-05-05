job "coder" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  group "app" {
    task "coder" {
      driver = "docker"

      config {
        image        = "ghcr.io/coder/coder:latest"
        network_mode = "host"

        entrypoint = ["/bin/bash", "-c"]
        args       = ["/config/entrypoint.sh"]

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "${JOB_REMOTE_CONFIGS_DIR}:/config:ro",
          "${JOB_REMOTE_SECRETS_DIR}:/run/coder-secrets:ro",
        ]
      }

      env {
        CODER_HTTP_ADDRESS = "127.0.0.1:13300"
        CODER_ACCESS_URL   = "https://coder.cdayz.ru"

        CODER_OIDC_ISSUER_URL            = "https://auth.cdayz.ru"
        CODER_OIDC_CLIENT_ID             = "coder"
        CODER_OIDC_EMAIL_DOMAIN          = "cdayz.ru"
        CODER_OIDC_SCOPES                = "openid,profile,email"
        CODER_OIDC_IGNORE_EMAIL_VERIFIED = "true"
        CODER_OIDC_EMAIL_FIELD           = "email"
        CODER_OIDC_USERNAME_FIELD        = "preferred_username"

        CODER_DISABLE_PASSWORD_AUTH                 = "true"
        CODER_OAUTH2_GITHUB_DEFAULT_PROVIDER_ENABLE = "false"

        TF_CLI_CONFIG_FILE = "/config/terraformrc"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }
  }
}