{ pkgs, ... }:

let
  dbipCityLiteGz = pkgs.fetchurl {
    url = "https://cdn.jsdelivr.net/npm/dbip-city-lite/dbip-city-lite.mmdb.gz";
    hash = "sha256-sIb1DGVNmvV0B3ltTcT4yQkMMMiZt89X0eDIzT0U/r8=";
  };

  geoipDb = pkgs.runCommand "dbip-city-lite-mmdb" { } ''
    mkdir -p $out
    ${pkgs.gzip}/bin/gzip -dc ${dbipCityLiteGz} > $out/GeoLite2-City.mmdb
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/geoip 0755 root root -"
    "L+ /var/lib/geoip/GeoLite2-City.mmdb - - - - ${geoipDb}/GeoLite2-City.mmdb"
  ];
}
