id        = "prometheus-data"
name      = "prometheus-data"
type      = "csi"
plugin_id = "zfs-local-dataset"

capacity_min = "10GiB"
capacity_max = "50GiB"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}