{
  services.openssh.openFirewall = false;

  networking.firewall = {
    enable = true;

    allowPing = true;
    logRefusedConnections = false;

    allowedTCPPorts = [ ];

    extraCommands = ''
      # SSH from LAN and tailnet
      iptables -I nixos-fw 3 -p tcp --dport 22 -s 192.168.0.0/16 -j nixos-fw-accept
      iptables -I nixos-fw 3 -p tcp --dport 22 -s 100.64.0.0/10 -j nixos-fw-accept
    '';

    extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 22 -s 192.168.0.0/16 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 22 -s 100.64.0.0/10 -j nixos-fw-accept || true
    '';
  };
}
