id        = "valkey-data"
name      = "valkey-data"
type      = "csi"
plugin_id = "zfs-local-dataset"

capacity_min = "1GiB"
capacity_max = "10GiB"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}