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

      MaxAuthTries = 3;
      LoginGraceTime = "30s";
    };

    extraConfig = ''
      AllowUsers crazy
    '';
  };
}
