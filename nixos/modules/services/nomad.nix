{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nomad
  ];

  services.nomad = {
    enable = true;

    settings = {
      datacenter = "homelab";
      region = "global";

      data_dir = "/var/lib/nomad";

      bind_addr = "127.0.0.1";

      advertise = {
        http = "127.0.0.1";
        rpc = "127.0.0.1";
        serf = "127.0.0.1";
      };

      server = {
        enabled = true;
        bootstrap_expect = 1;
      };

      client = {
        enabled = true;
        alloc_dir = "/var/lib/nomad/alloc";
        alloc_mounts_dir = "/var/lib/nomad/alloc_mounts";

        options = {
          "driver.docker.enable" = "true";
        };
      };

      ui.enabled = true;

      telemetry = {
        collection_interval = "1s";
        disable_hostname = true;
        prometheus_metrics = true;
        publish_allocation_metrics = true;
        publish_node_metrics = true;
      };
    };
  };

}
