{ ... }:

let
  uplink = "enp3s0"; # порт в сторону роутера / остальной сети
  downlink = "eno1"; # порт в сторону второго устройства / свитча
in
{
  systemd.network.netdevs."10-br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
    bridgeConfig = {
      STP = false;
      ForwardDelaySec = 0;
    };
  };

  systemd.network.networks."10-${uplink}" = {
    matchConfig.Name = uplink;
    networkConfig = {
      Bridge = "br0";
      LinkLocalAddressing = "no";
    };
    linkConfig.RequiredForOnline = "enslaved";
  };

  systemd.network.networks."10-${downlink}" = {
    matchConfig.Name = downlink;
    networkConfig = {
      Bridge = "br0";
      LinkLocalAddressing = "no";
    };
    linkConfig.RequiredForOnline = "no";
  };

  systemd.network.networks."20-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
