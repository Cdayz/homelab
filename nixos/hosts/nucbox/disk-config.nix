{ lib, ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-TWSC_TSC3AN1T0-F6Q10S_TTSQA2587X07704";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };

          zfs = {
            size = "100%";

            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };

    zpool.rpool = {
      type = "zpool";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        compression = "zstd";
        acltype = "posixacl";
        xattr = "sa";
        mountpoint = "none";
      };

      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
        };

        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };

        var = {
          type = "zfs_fs";
          mountpoint = "/var";
        };

        home = {
          type = "zfs_fs";
          mountpoint = "/home";
        };
      };
    };
  };
}
