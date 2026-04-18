{
  description = "Homelab NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations.nucbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          sops-nix.nixosModules.sops
          ./hosts/nucbox/configuration.nix
        ];
      };
  };
}
