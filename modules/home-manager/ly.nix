{
  lib,
  pkgs,
  inputs,
  config,
  ...
} : 
  let 

    inherit (lib) types mkIf;
    mkOpt = config.eula.lib.options.mkOpt;

  in {

    options.eula.modules.home-manager.ly = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.eula.modules.home-manager.ly.enable {
      home-manager.users.eulalia = { # TODO FIX USERNAME MAPPING
	home.packages = [
	  pkgs.ly
        ];
      };
    };
  }
