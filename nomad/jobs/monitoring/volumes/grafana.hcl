id        = "grafana-data"
name      = "grafana-data"
type      = "csi"
plugin_id = "zfs-local-dataset"

capacity_min = "1GiB"
capacity_max = "5GiB"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}
