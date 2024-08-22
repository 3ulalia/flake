{
  inputs,
  lib,
  pkgs,
  config,
  osConfig,
  ...
} : 
  let 
    inherit (lib) filter head split types mkIf trace mkAliasDefinitions;
    inherit (osConfig.eula.lib.helpers) list-to-attrs;
    mkOpt = osConfig.eula.lib.options.mkOpt;

    configs-to-enabled-settings = cfgs:  
      list-to-attrs (map 
	(n: {${config.eula.modules.home-manager.niri.${n}.pkg.pname}.enable = true;})
	(filter (n: config.eula.modules.home-manager.niri.${n}.enable) cfgs));
  in {

    options.eula.modules.home-manager.niri = {
      enable = mkOpt types.bool false;  
      launcher = {
	enable = mkOpt types.bool true;
	pkg = mkOpt types.package pkgs.fuzzel;
      };
      bg = {
	enable = mkOpt types.bool true;
	pkg = mkOpt types.package pkgs.swww;
      };
      notif = {
	enable = mkOpt types.bool true;
	pkg = mkOpt types.package pkgs.mako;
      };
      bar = {
	enable = mkOpt types.bool true;
	pkg = mkOpt types.package pkgs.waybar;
      };
      brightness = {
	enable = mkOpt types.bool true;
	pkg = mkOpt types.package pkgs.wluma;
      };
      night-shift = {
	enable = mkOpt types.bool true;
      }; 
      locker = {
	enable = mkOpt types.bool true;
	pkg = mkOpt types.package pkgs.swaylock-effects;
      };
    };

    config = mkIf (trace "enabled niri HM module for a user!" config.eula.modules.home-manager.niri.enable) {

      home = let opts = config.eula.modules.home-manager.niri; in { 
	# home-manager settings
	
       	# TODO break pkgs out into own modules
	
	packages = [   
	  pkgs.niri
	  (mkIf config.eula.modules.home-manager.niri.locker.enable config.eula.modules.home-manager.niri.locker.pkg)
	  (mkIf config.eula.modules.home-manager.niri.bg.enable config.eula.modules.home-manager.niri.bg.pkg)
        ];
      };

      programs = configs-to-enabled-settings ["bar" "launcher"];   

      services = (configs-to-enabled-settings ["notif"]) // {
        
	gammastep = {
      	  enable = mkIf config.eula.modules.home-manager.niri.night-shift.enable true;
	  # TODO: investigate a fix (mozilla location service no longer exists)
    	  provider = "manual"; #if osConfig.services.geoclue2.enable then "geoclue2" else "manual";
  	  latitude = 42.36; # Boston
  	  longitude = -71.06;
        };
      };
    };
  }
