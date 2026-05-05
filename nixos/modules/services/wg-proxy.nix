{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    socat
  ];

  systemd.services.wg-http-proxy-lan-forward = {
    description = "Expose wg-http-proxy loopback port to LAN";
    after = [
      "network-online.target"
      "nomad.service"
    ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:13129,bind=192.168.1.136,fork,reuseaddr TCP:127.0.0.1:13128";
      Restart = "always";
      RestartSec = "2s";
    };

    wantedBy = [ "multi-user.target" ];
  };

  networking.firewall.extraCommands = ''
    iptables -I nixos-fw 1 -p tcp --dport 13129 -s 192.168.0.0/16 -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 13129 -s 192.168.0.0/16 -j nixos-fw-accept || true
  '';
}
