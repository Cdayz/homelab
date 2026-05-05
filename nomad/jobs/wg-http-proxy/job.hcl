job "wg-http-proxy" {
  region      = "global"
  datacenters = ["homelab"]
  type        = "service"

  group "proxy" {
    network {
      mode = "bridge"

      port "http_proxy" {
        static       = 13128
        to           = 3128
        host_network = "loopback"
      }
    }

    task "proxy" {
      driver = "docker"

      config {
        image = "wg-squid-proxy:local"
        ports = ["http_proxy"]

        cap_add = [
          "NET_ADMIN",
        ]

        devices = [
          {
            host_path          = "/dev/net/tun"
            container_path     = "/dev/net/tun"
            cgroup_permissions = "rwm"
          }
        ]

        sysctl = {
          "net.ipv4.conf.all.src_valid_mark" = "1"
        }

        volumes = [
          "${JOB_REMOTE_SECRETS_DIR}/wg0.conf:/run/wg-secrets/wg0.conf:ro",
          "${JOB_REMOTE_SECRETS_DIR}/squid_htpasswd:/run/squid-secrets/htpasswd:ro",
        ]
      }

      resources {
        cpu    = 300
        memory = 256
      }
    }
  }
}
