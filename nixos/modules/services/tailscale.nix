{ ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
  };

  # exit node: форвард телефона через бокс (docker раньше включал это сам)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
