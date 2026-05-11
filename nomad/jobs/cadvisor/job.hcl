job "cadvisor" {
  datacenters = ["homelab"]
  type        = "system"

  meta {
    deploy_id = "${JOB_DEPLOY_ID}"
  }

  group "cadvisor" {
    network {
      port "http" {
        static       = 18181
        to           = 8080
        host_network = "loopback"
      }
    }

    task "cadvisor" {
      driver = "docker"

      config {
        image = "ghcr.io/google/cadvisor:0.55.1"
        ports = ["http"]

        args = [
          "-housekeeping_interval=15s",
          "-docker_only=true",
          "-store_container_labels=false",
          "-whitelisted_container_labels=com.hashicorp.nomad.job_name,com.hashicorp.nomad.task_name,com.hashicorp.nomad.task_group_name,com.hashicorp.nomad.alloc_id",
        ]

        privileged = true

        mount {
          type     = "bind"
          source   = "/"
          target   = "/rootfs"
          readonly = true
        }

        mount {
          type   = "bind"
          source = "/var/run"
          target = "/var/run"
        }

        mount {
          type     = "bind"
          source   = "/sys"
          target   = "/sys"
          readonly = true
        }

        mount {
          type     = "bind"
          source   = "/var/lib/docker"
          target   = "/var/lib/docker"
          readonly = true
        }
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}