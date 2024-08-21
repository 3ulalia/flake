{
  config,
  inputs,
  lib,
  pkgs,
  ...
} : 
  let 
    inherit (builtins) length;
    inherit (lib) mkOption mkIf mkAliasDefinitions trace types;
    inherit (config.eula.lib.helpers) list-to-attrs;
    inherit (config.eula.lib.options) mkOpt;
  in {

    options.eula.modules.services.ly.enable = mkOpt types.bool false;
    
    config = mkIf config.eula.modules.services.ly.enable {
      services.displayManager.ly.enable = (trace "ly is enabled systemwide!" true);
    };
}
	      
