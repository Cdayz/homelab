job "hostpath-csi-plugin" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "system"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "csi" {
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

        labels = {
          "com.hashicorp.nomad.job_name"        = "${NOMAD_JOB_NAME}"
          "com.hashicorp.nomad.task_group_name" = "${NOMAD_GROUP_NAME}"
          "com.hashicorp.nomad.task_name"       = "${NOMAD_TASK_NAME}"
          "com.hashicorp.nomad.alloc_id"        = "${NOMAD_ALLOC_ID}"
        }
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
