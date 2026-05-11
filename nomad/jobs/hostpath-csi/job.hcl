job "hostpath-csi-plugin" {
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

      config {
        image      = "registry.k8s.io/sig-storage/hostpathplugin:v1.10.0"
        privileged = true

        args = [
          "--drivername=csi-hostpath",
          "--v=5",
          "--endpoint=${CSI_ENDPOINT}",
          "--nodeid=node-${NOMAD_ALLOC_INDEX}",
        ]
      }

      csi_plugin {
        id        = "hostpath"
        type      = "monolith"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 256
        memory = 128
      }
    }
  }
}
