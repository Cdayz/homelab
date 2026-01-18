{ lib, ... }:

{
  systemd.defaultUnit = lib.mkForce "multi-user.target";
}
