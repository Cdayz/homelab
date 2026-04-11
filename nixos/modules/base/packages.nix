{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    fish
  ];
  programs.fish.enable = true;
}
