{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
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
  ];
  programs.fish.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
