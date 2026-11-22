{ config, ... }:

{
  networking.wireless = {
    enable = true;
    interfaces = [ "wifi0" ];
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

  # фиксированное имя вместо предиктабельного: матч по MAC (Driver= в uevent
  # на раннем буте может быть ещё пуст — race), Name= обязателен, иначе
  # link-файл перебивает 99-default.link и остаётся kernel-имя wlan0
  systemd.network.links."10-wifi" = {
    matchConfig.MACAddress = "4c:23:38:b8:4c:ff";
    extraConfig = ''
      Name=wifi0
      WirelessPowersave=false
    '';
  };

  systemd.network.networks."30-wlan" = {
    matchConfig.Name = "wifi0";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = false;
    };
    # wlan — запасной линк, у br0 метрика ниже
    dhcpV4Config.RouteMetric = 300;
    ipv6AcceptRAConfig.RouteMetric = 300;
    linkConfig.RequiredForOnline = "routable";
  };

  # network-online при любом из линков (br0/wlan), чтобы boot без провода не висел на wait-online
  systemd.network.wait-online.anyInterface = true;
}
