{
  lib,
  pkgs,
  inputs,
  config,
  osConfig,
  ...
} : 
  let 

    inherit (lib) types mkIf;
    mkOpt = osConfig.eula.lib.options.mkOpt;

  in {

    options.eula.modules.home-manager.ly = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.eula.modules.home-manager.ly.enable {
	home.packages = [
	 # pkgs.ly
        ];
    };
  }
