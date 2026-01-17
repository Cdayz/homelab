{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      2222 # SSH
      80 # HTTP
      443 # HTTPS
    ];

    logRefusedConnections = true;
    trustedInterfaces = [ "cni+" ];
  };
}
