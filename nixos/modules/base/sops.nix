{ config, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/nucbox.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.test-secret = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
