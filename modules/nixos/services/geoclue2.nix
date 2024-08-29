{
  config,
  inputs,
  lib,
  pkgs,
  ...
} : 
  let 
    inherit (lib) mkDefault mkIf trace types;
    inherit (config.eula.lib.options) mkOpt;
  in {

    options.eula.modules.services.geoclue2.enable = mkOpt types.bool false;
    
    config = mkIf config.eula.modules.services.geoclue2.enable {
      services.geoclue2.enable = (trace "geoclue2 is enabled systemwide!" true);
      services.geoclue2.geoProviderUrl = mkDefault "https://beacondb.net/v1/geolocate";
    };
}
	      
