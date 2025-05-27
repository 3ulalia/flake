{ osConfig, pkgs, ... } : {
  eula.modules.home-manager.desktop.apps.night-shift = {
    pkg = pkgs.gammastep;
    enable = true;
    type = "services";
  };
  services.gammastep = {
    provider = 
      if osConfig.services.geoclue2.enable
      then "geoclue2"
      else "manual";
    # us-east
    latitude = 42.36;
    longitude = -71.06;
  };
}
