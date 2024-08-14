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

    imports = [inputs.niri.nixosModules.niri];

    options.eula.modules.home-manager.niri = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.eula.modules.home-manager.niri.enable {
      home = { 

	# home-manager settings

	# TODO break pkgs out into own modules
	# TODO configure niri to find these packages
	packages = [ 
          pkgs.wofi
          pkgs.fuzzel
          pkgs.swww
          pkgs.mako
	  pkgs.xdg-desktop-portal-gnome
        ];

	xdg.portal.config.common.default = "*";
	xdg.portal.enable = true;
	xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gnome];
      };
    };
  }
