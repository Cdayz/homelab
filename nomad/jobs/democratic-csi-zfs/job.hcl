job "democratic-csi-zfs" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "system"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "csi" {

    restart {
      attempts = 10
      delay    = "15s"
      interval = "5m"
      mode     = "delay"
    }

    task "plugin" {
      driver = "docker"

      env {
        CSI_NODE_ID          = "${attr.unique.hostname}"
        USE_HOST_MOUNT_TOOLS = "0"
        PATH                 = "/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
      }

      config {
        image        = "docker.io/democraticcsi/democratic-csi:latest"
        privileged   = true
        ipc_mode     = "host"
        network_mode = "host"

        command = "democratic-csi"

        args = [
          "--csi-version=1.11.0",
          "--csi-name=zfs-local-dataset",
          "--driver-config-file=/local/driver.yaml",
          "--log-level=debug",
          "--csi-mode=controller",
          "--csi-mode=node",
          "--server-socket=/csi/csi.sock",
        ]

        mount {
          type     = "bind"
          source   = "/"
          target   = "/host"
          readonly = false
        }

        mount {
          type     = "bind"
          source   = "/srv/nomad-csi"
          target   = "/srv/nomad-csi"
          readonly = false
        }

        mount {
          type     = "bind"
          source   = "/nix"
          target   = "/nix"
          readonly = true
        }

        mount {
          type     = "bind"
          source   = "/run/current-system/sw"
          target   = "/run/current-system/sw"
          readonly = true
        }
      }

      template {
        destination = "local/driver.yaml"
        data        = file("${JOB_REMOTE_CONFIGS_DIR}/driver.yaml")
      }

      csi_plugin {
        id        = "zfs-local-dataset"
        type      = "monolith"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}