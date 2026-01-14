{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: 

let
  conf = config.eula.modules.home-manager.desktop.apps.night-shift;
  configure-huh = (conf.pkg == pkgs.gammastep) && conf.opinionated && conf.enable;
in  {
  eula.modules.home-manager.desktop.apps.night-shift.type = lib.mkIf configure-huh "services";
  services.gammastep = lib.mkIf configure-huh {
    provider =
      if osConfig.services.geoclue2.enable
      then "geoclue2"
      else "manual";
    # us-east
    latitude = 42.36;
    longitude = -71.06;
  };
}
