{ ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "processes"
      "diskstats"
      "filesystem"
      "netstat"
      "hwmon"
    ];
    port = 9100;
    listenAddress = "127.0.0.1";
  };
}
