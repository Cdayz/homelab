{ config, ... }:

{
  networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
    # psk живёт в sops-шаблоне, в nix store попадает только ссылка ext:wifi_psk
    secretsFile = config.sops.templates."wifi.env".path;
    networks.XOLODEC = {
      pskRaw = "ext:wifi_psk";
      # hidden = true;
    };
  };

  # br0 и wlan в одном L2: без этого ядро отвечает на ARP за IP соседнего
  # интерфейса и роутер уводит проводной трафик на wifi
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
  };

  systemd.network.links."10-wifi" = {
    matchConfig.Driver = "mt7921e";
    extraConfig = "WirelessPowersave=false";
  };

  systemd.network.networks."30-wlan" = {
    matchConfig.Name = "wlp2s0";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    # wlan — запасной линк, у br0 метрика ниже
    dhcpV4Config.RouteMetric = 300;
    ipv6AcceptRAConfig.RouteMetric = 300;
    linkConfig.RequiredForOnline = "routable";
  };

  # network-online при любом из линков (br0/wlan), чтобы boot без провода не висел на wait-online
  systemd.network.wait-online.anyInterface = true;
}
