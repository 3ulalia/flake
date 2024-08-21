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

    options.eula.modules.home-manager.signal-desktop = {
      enable = mkOpt types.bool false;  
    };

    config = mkIf config.eula.modules.home-manager.signal-desktop.enable {

      home.packages = [pkgs.signal-desktop];

      nixpkgs.overlays = [
	(self: super: {
	  signal-desktop = super.signal-desktop.overrideAttrs (old: {
	    preFixup = old.preFixup + ''
	      gappsWrapperArgs+=(
		--add-flags "--enable-features=UseOzonePlatform"
		--add-flags "--ozone-platform=wayland"
	      )
	    '';
	  });
	})
      ];
    };
  }
