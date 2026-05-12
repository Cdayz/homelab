{
  services.openssh.openFirewall = false;

  networking.firewall = {
    enable = true;

    allowPing = true;
    logRefusedConnections = false;

    allowedTCPPorts = [
      80
      443
    ];

    extraCommands = ''
      # SSH from LAN
      iptables -I nixos-fw 3 -p tcp --dport 22 -s 192.168.0.0/16 -j nixos-fw-accept
    '';

    extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 22 -s 192.168.0.0/16 -j nixos-fw-accept || true
    '';
  };
}
