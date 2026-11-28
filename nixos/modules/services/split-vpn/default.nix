{ config, lib, pkgs, ... }:

let
  vlessUri = config.sops.secrets."vpn/vless-uri".path;

  # какие домены куда: domains.json
  domainsFile = ./domains.json;

  makeConfig = pkgs.writers.writePython3 "make-singbox" { } (
    builtins.readFile ./make-singbox.py
  );

  generateRuleset = pkgs.writers.writePython3 "generate-ruleset" { } (
    builtins.readFile ./generate-ruleset.py
  );

  updateRuleset = pkgs.writers.writeBash "update-ruleset" { } (
    builtins.readFile ./update-ruleset.sh
  );

  commonHardening = {
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    ProtectHome = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    UMask = "0077";
  };
in
{
  sops.secrets."vpn/vless-uri" = {
    restartUnits = [ "split-vpn.service" ];
  };

  systemd.services.split-vpn-ruleset = {
    description = "antizapret rule-set from antifilter.download";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    before = [ "split-vpn.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.curl
      pkgs.findutils
      pkgs.gnugrep
      pkgs.sing-box
      pkgs.systemd
    ];

    serviceConfig = commonHardening // {
      Type = "oneshot";
      StateDirectory = "split-vpn";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/split-vpn" ];
      ExecStart = "${updateRuleset} ${generateRuleset}";
    };
  };

  systemd.timers.split-vpn-ruleset = {
    description = "Daily antizapret rule-set refresh";
    timerConfig = {
      OnCalendar = "*-*-* 04:40:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.split-vpn = {
    description = "Split VPN egress: openai + antizapret via vless, rest direct";
    after = [
      "network-online.target"
      "split-vpn-ruleset.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "split-vpn-ruleset.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = commonHardening // {
      Type = "simple";
      RuntimeDirectory = "split-vpn";
      StateDirectory = "split-vpn";
      ExecStartPre = [
        "${makeConfig} /run/split-vpn/config.json ${domainsFile} ${vlessUri}"
        "${pkgs.sing-box}/bin/sing-box check -c /run/split-vpn/config.json"
      ];
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /run/split-vpn/config.json";
      Restart = "always";
      RestartSec = "5";
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
      ];
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/split-vpn" ];
    };
  };
}
