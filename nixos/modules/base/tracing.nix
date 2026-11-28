{ pkgs, config, ... }:
{

  programs.bcc.enable = !pkgs.stdenv.hostPlatform.isRiscV;
  # sysdig: не собирается под ядро 6.18 (scap.ko), вернём когда починят
  # programs.sysdig.enable = !pkgs.stdenv.isAarch64 && !pkgs.stdenv.hostPlatform.isRiscV;

  environment.systemPackages = [
    pkgs.strace

    # low priority so that we can to use trace from bcc
    (pkgs.lowPrio config.boot.kernelPackages.perf)
  ];
}
