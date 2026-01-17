{
  description = "Cdayz homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nucbox = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          ./nixos/hosts/nucbox/configuration.nix
        ];
      };
    };
}
