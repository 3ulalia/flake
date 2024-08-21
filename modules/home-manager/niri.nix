{
  inputs,
  lib,
  pkgs,
  config,
  osConfig,
  ...
} : 
  let 
    inherit (lib) types mkIf trace mkAliasDefinitions;
    mkOpt = osConfig.eula.lib.options.mkOpt;
  in {

    options.eula.modules.home-manager.niri = {
      enable = mkOpt types.bool false;  
    };

    config = mkIf (trace "enabled niri HM module for a user!" config.eula.modules.home-manager.niri.enable) {

      home = { 

	# home-manager settings
	
       	# TODO break pkgs out into own modules
	# TODO configure niri to find these packages
	packages = [ 
	  pkgs.niri
          pkgs.wofi
          pkgs.fuzzel
          pkgs.swww
          pkgs.mako
	  pkgs.gnome-keyring
	  pkgs.waybar
        ];
      };

     # programs.niri.enable = true;

    };
  }
