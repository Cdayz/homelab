{ pkgs, lib, ... }:

{
  users.groups.nomad = { };

  users.users.nomad = {
    isSystemUser = true;
    group = "nomad";
    extraGroups = [ "docker" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nomad 0755 nomad nomad -"
    "d /var/lib/nomad/server 0755 nomad nomad -"
    "d /var/lib/nomad/client 0755 nomad nomad -"
    "d /var/lib/nomad/alloc 0755 nomad nomad -"
    "d /var/lib/nomad/alloc_mounts 0755 nomad nomad -"

    "z /var/lib/nomad 0755 nomad nomad -"
    "z /var/lib/nomad/server 0755 nomad nomad -"
    "z /var/lib/nomad/client 0755 nomad nomad -"
    "z /var/lib/nomad/alloc 0755 nomad nomad -"
    "z /var/lib/nomad/alloc_mounts 0755 nomad nomad -"

    "d /var/lib/nomad-volumes 0755 root root -"
    "d /var/lib/nomad-csi-volumes 0755 root root -"
  ];

  environment.systemPackages = with pkgs; [
    nomad
    cni-plugins
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

        cni_path = "${pkgs.cni-plugins}/bin";

        options = {
          "driver.docker.enable" = "true";
          "docker.volumes.enabled" = "true";
        };

        host_network = {
          loopback = {
            interface = "lo";
            cidr = "127.0.0.0/8";
          };
        };
      };

      plugin.docker.config = {
        allow_privileged = true;

        volumes = {
          enabled = true;
        };
      };

      ui.enabled = true;

      plugin.raw_exec.config.enabled = true;

      telemetry = {
        collection_interval = "1s";
        disable_hostname = true;
        prometheus_metrics = true;
        publish_allocation_metrics = true;
        publish_node_metrics = true;
      };
    };
  };

  systemd.services.nomad.serviceConfig = {
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce null;
  };
}
