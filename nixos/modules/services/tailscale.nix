{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
  };

  # tailscale warn'ит: без GRO форвардинг через exit node медленнее
  systemd.services.tailscale-gro-fix = {
    description = "Enable UDP GRO forwarding on br0 (exit node throughput)";
    after = [ "systemd-networkd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.ethtool}/bin/ethtool -K br0 rx-udp-gro-forwarding on"
        "${pkgs.ethtool}/bin/ethtool -K br0 rx-gro-list off"
      ];
    };
  };

  # exit node: форвард телефона через бокс (docker раньше включал это сам)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
