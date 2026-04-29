{
  networking.firewall = {
    enable = true;

    allowPing = true;
    logRefusedConnections = false;

    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
    ];

    extraInputRules = ''
      # allow ssh from LAN
      ip saddr 192.168.0.0/16 tcp dport 22 accept

      # drop everything else to ssh
      tcp dport 22 drop
    '';
  };
}
