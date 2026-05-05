{ ... }:

{
  imports = [
    ./ssh.nix
    ./fail2ban.nix
    ./nomad.nix
    ./caddy.nix
    ./monitoring
    ./wg-proxy.nix
  ];
}
