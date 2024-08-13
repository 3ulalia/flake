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

    options.eula.modules.niri = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.eula.modules.niri.enable {
      home-manager.users.eulalia.home = { # TODO FIX USERNAME MAPPING

	imports = [inputs.niri.homeModules.niri];

	packages = [
          pkgs.wofi
          pkgs.swww
          pkgs.mako
        ];
      };
      programs.niri.enable = true;
    };
  }
