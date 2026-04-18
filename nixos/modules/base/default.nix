{ ... }:

{
  imports = [
    ./users.nix
    ./locale.nix
    ./timezone.nix
    ./sudo.nix
    ./packages.nix
    ./journald.nix
    ./cleaning.nix
    ./bootloader.nix
    ./power.nix
    ./docker.nix
    ./sops.nix
  ];

  nixpkgs.config.allowUnfree = true;
}
