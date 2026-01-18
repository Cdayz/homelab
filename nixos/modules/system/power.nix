{ ... }:

{
  services.logind.settings.Login = {
    IdleAction = "ignore";
    IdleActionSec = 0;

    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "ignore";

    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
