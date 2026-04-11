{ ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
      PermitEmptyPasswords = "no";

      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = "yes";
      PermitUserEnvironment = "no";
      UseDns = false;
      UsePAM = true;

      MaxAuthTries = 3;
      MaxSessions = 4;
      MaxStartups = "10:30:60";
      LoginGraceTime = "30s";

      AllowUsers = [ "nikita" ];
    };
  };
}