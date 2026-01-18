# Homelab

## Stack

- NixOS

## Bootstrap

1. Install NixOS
2. Copy age key to /var/lib/sops-nix/key.txt
3. git clone https://github.com/Cdayz/homelab
4. nixos-rebuild switch --flake .#nucbox
