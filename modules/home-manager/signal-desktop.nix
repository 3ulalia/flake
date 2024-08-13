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

    options.eula.modules.home-manager.signal-desktop = {
      enable = mkOpt types.bool false;  
    };

    config = mkIf config.eula.modules.home-manager.signal-desktop.enable {

      home-manager.users.eulalia.home.packages = [pkgs.signal-desktop];

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
