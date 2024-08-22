{
  config,
  inputs,
  lib,
  pkgs,
  ...
} : 
  let 
    inherit (lib) mkIf trace types;
    inherit (config.eula.lib.options) mkOpt;
  in {

    options.eula.modules.services.geoclue2.enable = mkOpt types.bool false;
    
    config = mkIf config.eula.modules.services.geoclue2.enable {
      services.geoclue2.enable = (trace "ly is enabled systemwide!" true);
    };
}
	      
