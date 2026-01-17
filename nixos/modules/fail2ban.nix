{ ... }:

{
  services.fail2ban = {
    enable = true;

    extraSettings = {
      bantime = "1h";
      findtime = "10m";
      maxretry = 5;
    };

    jails = {
      sshd = {
        enabled = true;
        backend = "systemd";
      };
    };
  };
}
