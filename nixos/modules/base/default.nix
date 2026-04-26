{ options, ... }:

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
    ./terminfo.nix
    ./tracing.nix
    ./trusted-nix-caches.nix
    ./well-known-hosts.nix
  ];

  nixpkgs.config.allowUnfree = true;

  environment = {
    # Print the URL instead on servers
    variables.BROWSER = "echo";
    # Don't install the /lib/ld-linux.so.2 and /lib64/ld-linux-x86-64.so.2
    # stubs. Server users should know what they are doing.
    stub-ld.enable = false;
  };

  # No need for fonts on a server
  fonts.fontconfig.enable = false;

  # Prevent LLMNR poisoning attacks
  services.resolved = (
    # TODO: remove when 25.11 is deprecated
    if options.services.resolved ? settings then
      {
        settings.Resolve.LLMNR = "false";
      }
    else
      {
        llmnr = "false";
      }
  );
}
