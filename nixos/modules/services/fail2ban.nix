{ ... }:

{
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "192.168.1.0/24"
    ];

    bantime = "24h";
    bantime-increment = {
      enable = true;
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      maxtime = "168h";
      overalljails = true;
    };

    jails = {
      sshd.settings = {
        enabled = true;
        backend = "systemd";
      };
    };
  };
}
