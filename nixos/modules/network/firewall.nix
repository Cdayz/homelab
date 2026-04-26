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
  };
}
