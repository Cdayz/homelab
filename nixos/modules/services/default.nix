{ ... }:

{
  imports = [
    ./ssh.nix
    ./split-vpn
    ./tailscale.nix
    ./monitoring
  ];
}
