{ ... }:

{
  systemd.network.networks."10-ethernet" = {
    matchConfig.Name = "enp3s0";

    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = false;
      LinkLocalAddressing = "ipv4";
    };

    dhcpV4Config = {
      RouteMetric = 100;
    };
  };
}
