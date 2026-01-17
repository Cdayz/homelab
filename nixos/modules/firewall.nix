{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
    ];

    logRefusedConnections = true;
  };
}
