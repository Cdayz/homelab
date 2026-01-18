{ config, lib, ... }:

{

  sops.secrets."wifi/psk" = {
    sopsFile = ../../secrets/wifi.yaml;
    key = "psk";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  systemd.services.NetworkManager.wantedBy = [ "multi-user.target" ];
  systemd.services.NetworkManager-ensure-profiles.after = [ "NetworkManager.service" ];

  networking.useDHCP = lib.mkForce true;
  networking.nftables.enable = true;

  networking.networkmanager.ensureProfiles.profiles = {
    "wifi-home" = {
      connection = {
        id = "wifi-home";
        type = "wifi";
        autoconnect = true;
        permissions = "";
        interface-name = "wlp2s0";
      };

      wifi = {
        ssid = "XOLODEC";
        mode = "infrastructure";
        cloned-mac-address = "permanent";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk-file = "@${config.sops.secrets."wifi/psk".path}";
      };

      ipv4.method = "auto";
      ipv6.method = "ignore";
    };
  };

}
