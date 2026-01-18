{ ... }:

{
  imports = [
    ./firewall.nix
    ./wifi.nix
    ./ethernet.nix
  ];

  networking.useNetworkd = true;
  systemd.network.enable = true;

  networking.networkmanager.enable = false;

  systemd.services.systemd-networkd-wait-online.enable = true;

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
  };

}
