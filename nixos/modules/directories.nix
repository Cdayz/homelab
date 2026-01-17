{
  systemd.tmpfiles.rules = [
    "d /srv 0755 root root -"
    "d /srv/k3s 0755 root root -"
    "d /srv/k3s/storage 0755 root root -"
  ];
}
