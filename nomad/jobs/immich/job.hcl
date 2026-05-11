job "immich" {
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

    volume "library" {
      type            = "csi"
      source          = "immich-library"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    volume "ml-cache" {
      type            = "csi"
      source          = "immich-ml-cache"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "machine-learning" {
      driver = "docker"

      config {
        image        = "ghcr.io/immich-app/immich-machine-learning:v2"
        network_mode = "host"
      }

      volume_mount {
        volume      = "ml-cache"
        destination = "/cache"
        read_only   = false
      }

      env {
        TZ = "Europe/Moscow"

        IMMICH_HOST = "127.0.0.1"
        IMMICH_PORT = "13003"
      }

      resources {
        cpu    = 500
        memory = 2048
      }
    }

    task "server" {
      driver = "docker"

      config {
        image        = "ghcr.io/immich-app/immich-server:v2"
        network_mode = "host"

        entrypoint = ["tini", "--", "/bin/bash", "-c"]
        command    = "/local/start-immich.sh"

        volumes = [
          "${JOB_REMOTE_CONFIGS_DIR}:/run/immich-configs:ro",
          "${JOB_REMOTE_SECRETS_DIR}:/run/immich-secrets:ro",
        ]
      }

      volume_mount {
        volume      = "library"
        destination = "/data"
        read_only   = false
      }

      template {
        destination = "local/start-immich.sh"
        perms       = "0755"
        data        = <<EOF
        #!/bin/sh
        set -euox pipefail

        mkdir -p /tmp/immich-config

        OIDC_SECRET="$(cat /run/immich-secrets/oidc_client_secret)"

        sed "s|__IMMICH_OIDC_CLIENT_SECRET__|${OIDC_SECRET}|g" \
        /run/immich-configs/immich.yml \
        > /tmp/immich-config/immich.yml

        export IMMICH_CONFIG_FILE=/tmp/immich-config/immich.yml

        /bin/bash /usr/src/app/server/bin/start.sh
        EOF
      }

      env {
        TZ = "Europe/Moscow"

        DB_HOSTNAME      = "127.0.0.1"
        DB_PORT          = "15432"
        DB_DATABASE_NAME = "immich"
        DB_USERNAME      = "immich"

        REDIS_HOSTNAME = "127.0.0.1"
        REDIS_PORT     = "16379"
        REDIS_DBINDEX  = "1"

        DB_PASSWORD_FILE    = "/run/immich-secrets/db_password"
        REDIS_PASSWORD_FILE = "/run/immich-secrets/valkey_password"

        IMMICH_HOST        = "127.0.0.1"
        IMMICH_PORT        = "12283"
        IMMICH_ALLOW_SETUP = "false"

        IMMICH_TRUSTED_PROXIES      = "127.0.0.1"
        IMMICH_LOG_LEVEL            = "log"
        IMMICH_MACHINE_LEARNING_URL = "http://127.0.0.1:13003"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }
  }
}
