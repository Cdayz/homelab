{ config, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/nucbox.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets.test-secret = { };

    secrets."wifi/psk" = { };

    templates."wifi.env" = {
      owner = "wpa_supplicant";
      content = ''
        wifi_psk=${config.sops.placeholder."wifi/psk"}
      '';
    };
  };
}
