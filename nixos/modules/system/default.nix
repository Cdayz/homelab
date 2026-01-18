{ ... }:

{
  imports = [
    ./bootloader.nix
    ./default-unit.nix
    ./directories.nix
    ./journald.nix
    ./locale.nix
    ./packages.nix
    ./power.nix
    ./time-zone.nix
    ./cleanup.nix
    ./virt.nix
  ];

  nixpkgs.config.allowUnfree = true;
}
