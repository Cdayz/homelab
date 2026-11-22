{ config, lib, pkgs, ... }:

let
  awgConf = config.sops.secrets."vpn/awg-conf".path;

  # egress через VPN всегда: openai (geo-баны) + реестровый список antizapret
  domains = [
    "openai.com"
    "chatgpt.com"
    "oaistatic.com"
    "oaiusercontent.com"
    "sora.com"
    "cdn.auth0.com"
  ];

  domainsFile = pkgs.writeText "split-vpn-domains.json" (builtins.toJSON domains);

  # nixpkgs ждёт релизы amnezia с задержкой, а нужен протокол 3.1
  # (HeaderProtectionKey/RandomTrailers), поэтому оверрайдим src до v3.1
  # github-тарбаллы с бокса не скачать (Fastly v6 из РФ деградирован,
  # хэши тарбаллов к тому же нестабильны), поэтому fetchgit + nix copy с workstation
  amneziawgModule = config.boot.kernelPackages.amneziawg.overrideAttrs (old: {
    version = "3.1.20261113-2";
    src = pkgs.fetchgit {
      name = "amneziawg-linux-kernel-module-src";
      url = "https://github.com/amnezia-vpn/amneziawg-linux-kernel-module";
      rev = "v3.1.20261113-02";
      hash = "sha256-h8dbrsZW6DrbCBXE/PYN6f/hZty7GAshGArruDMn+z4=";
    };
  });

  amneziawgTools = pkgs.amneziawg-tools.overrideAttrs (old: {
    version = "3.1.20260812";
    src = pkgs.fetchgit {
      name = "amneziawg-tools-src";
      url = "https://github.com/amnezia-vpn/amneziawg-tools";
      rev = "v3.1.20260812";
      hash = "sha256-uVfS38jYMV7mOIU+VfEYxuMpNpuw2ffjgHNrPTX7vIk=";
    };
  });

  makeConfig = pkgs.writers.writePython3 "make-singbox" { } (
    builtins.readFile ./make-singbox.py
  );

  renderAwg = pkgs.writers.writePython3 "render-awg" { } (
    builtins.readFile ./render-awg.py
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
  boot.extraModulePackages = [ amneziawgModule ];

  sops.secrets."vpn/awg-conf" = { };

  systemd.services.split-vpn-awg = {
    description = "AmneziaWG 3.1 tunnel (awg0), Table=off + policy route 51820";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      amneziawgTools
      pkgs.iproute2
      pkgs.coreutils
    ];

    preStart = "${renderAwg} ${awgConf} /run/split-vpn/awg0.conf";
    # rtnl-autoload для type amneziawg не срабатывает; -d нужен потому что
    # rebuild:test не обновляет booted-system, а модуль в текущей генерации
    script = "${pkgs.kmod}/bin/modprobe -d /run/current-system/kernel-modules amneziawg && awg-quick up /run/split-vpn/awg0.conf";
    preStop = "awg-quick down /run/split-vpn/awg0.conf";

    serviceConfig = commonHardening // {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "split-vpn";
      # модуль ядра грузим сами (autoload не работает)
      ProtectKernelModules = false;
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_SYS_MODULE"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_SYS_MODULE"
      ];
    };
  };

  systemd.services.split-vpn = {
    description = "Split VPN egress: openai + antizapret via awg0, rest direct";
    after = [
      "network-online.target"
      "split-vpn-awg.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "split-vpn-awg.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = commonHardening // {
      Type = "simple";
      RuntimeDirectory = "split-vpn";
      StateDirectory = "split-vpn";
      ExecStartPre = [
        "${makeConfig} /run/split-vpn/config.json ${domainsFile}"
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
