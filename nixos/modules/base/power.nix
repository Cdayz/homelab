{ options, ... }:

{
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  systemd.sleep =
    # TODO: remove when 25.11 is deprecated
    if options.systemd.sleep ? settings then
      {
        settings.Sleep = {
          AllowSuspend = "no";
          AllowHibernation = "no";
        };
      }
    else
      {
        extraConfig = ''
          AllowSuspend=no
          AllowHibernation=no
        '';
      };

  # For more detail, see:
  #   https://0pointer.de/blog/projects/watchdog.html
  systemd.settings.Manager = {
    # systemd will send a signal to the hardware watchdog at half
    # the interval defined here, so every 7.5s.
    # If the hardware watchdog does not get a signal for 15s,
    # it will forcefully reboot the system.
    RuntimeWatchdogSec = "15s";
    # Forcefully reboot if the final stage of the reboot
    # hangs without progress for more than 30s.
    # For more info, see:
    #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
    RebootWatchdogSec = "30s";
    # Forcefully reboot when a host hangs after kexec.
    # This may be the case when the firmware does not support kexec.
    KExecWatchdogSec = "1m";
  };
}
