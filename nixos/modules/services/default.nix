{ ... }:

{
  imports = [
    ./auto-upgrade.nix
    ./fail2ban.nix
    ./ssh.nix
    ./nomad.nix
  ];
}
