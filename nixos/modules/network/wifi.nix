{ config, ... }:

{

  sops.secrets."wifi/wpa_supplicant.conf" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets."wifi/wpa_supplicant.conf".path;

    networks."XOLODEC" = {
      pskRaw = "ext:psk_home";
    };
  };

  systemd.services.wpa_supplicant = {
    wants = [
      "sops-install-secrets.service"
      "systemd-networkd.service"
    ];
    after = [
      "sops-install-secrets.service"
      "systemd-networkd.service"
    ];
  };

  systemd.network.networks."20-wifi" = {
    matchConfig.Name = "wlp2s0";

    networkConfig = {
      DHCP = "ipv4";
      DefaultRouteOnDevice = false;
    };

    dhcpV4Config = {
      RouteMetric = 600;
    };
  };

}
