{ ... }:
{

  # De-duplicate store paths using hardlinks except in containers
  # where the store is host-managed.
  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
