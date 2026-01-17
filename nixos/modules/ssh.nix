{
  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
      X11Forwarding = false;
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "no";
      UseDns = false;
    };
  };
}
