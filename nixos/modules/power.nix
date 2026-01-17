{ ... }:

{
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";

    powerKey = "ignore";
    powerKeyLongPress = "ignore";

    extraConfig = ''
      IdleAction=ignore
      IdleActionSec=0
    '';
  };

  # На всякий случай отключаем sleep targets
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
