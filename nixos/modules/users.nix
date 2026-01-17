{
  users.users.crazy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA_REPLACE_WITH_YOUR_KEY"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
}
