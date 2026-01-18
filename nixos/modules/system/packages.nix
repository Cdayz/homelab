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
  ];

  programs.fish.enable = true;
}
