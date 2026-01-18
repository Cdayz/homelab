{ ... }:

{
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "/home/crazy/homelab";
  };
}
