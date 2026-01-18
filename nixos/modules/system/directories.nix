{
  systemd.tmpfiles.rules = [
    "d /var/lib/nomad 0755 nomad nomad -"
    "d /var/lib/nomad/alloc 0755 nomad nomad -"
    "d /var/lib/nomad/alloc_mounts 0755 nomad nomad -"
  ];
}
