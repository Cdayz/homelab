{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    vim
    htop
    tmux
    curl
    wget
    age
    sops
    go-task
    fish
    jq
    dnsutils
  ];
  programs.fish.enable = true;

  nix.settings.experimental-features = [
    # for container in builds support
    "auto-allocate-uids"
    "cgroups"

    # for useful ssh
    "nix-command"
    "flakes"
  ];

  nix.settings.system-features = [
    "uid-range"
    "recursive-nix"
  ];
}
