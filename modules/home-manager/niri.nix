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
      home = { # TODO FIX USERNAME MAPPING

	# home-manager settings

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

      # nixos settings

      environment.pathsToLink = ["share/xdg-desktop-portal" "/share/applications"];
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri-unstable;
      services.pipewire.enable = true;
      nixpkgs.overlays = [inputs.niri.overlays.niri];
    };
  }
