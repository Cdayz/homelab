{ ... }:

{
  imports = [
    ./firewall.nix
    ./bridge.nix
    ./wifi.nix
  ];

  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.networkmanager.enable = false;
  systemd.network.enable = true;

}
