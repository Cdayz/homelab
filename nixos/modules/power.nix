{ ... }:

{
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";

    powerKey = "ignore";
    powerKeyLongPress = "ignore";

    settings.Login = {
      IdleAction = "ignore";
      IdleActionSec = 0;
    };
  };

  # Полностью отключаем sleep/suspend/hibernate targets
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
