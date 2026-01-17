{ pkgs, ... }:
{
  users.users.crazy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAEEcmbQUIAw2y6jWIRt1gDmflh+yV3vHT4ytyagEKIZ cdayz@MacBook-Air-Nikita.local"
    ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;
}
