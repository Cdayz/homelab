id        = "immich-library"
name      = "immich-library"
type      = "csi"
plugin_id = "zfs-local-dataset"

capacity_min = "100GiB"
capacity_max = "500GiB"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}