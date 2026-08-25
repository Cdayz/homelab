{
  description = "Homelab NixOS config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      disko,
      ...
    }:
    {
      nixosConfigurations.nucbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./hosts/nucbox/configuration.nix
        ];
      };
    };
}
