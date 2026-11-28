{ options, ... }:

{
  services.journald =
    if options.services.journald ? settings then
      {
        settings.Journal = {
          SystemMaxUse = "500M";
          MaxRetentionSec = "7day";
        };
      }
    else
      {
        extraConfig = ''
          SystemMaxUse=500M
          MaxRetentionSec=7day
        '';
      };
}
