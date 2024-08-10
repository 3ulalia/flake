{
  lib,
  pkgs,
  inputs,
  config,
  ...
} : 
  let 

  inherit (lib) types mkIf;
  inherit (lib.eula) mkOpt;

  in {

    imports = [inputs.niri.nixosModules.niri];

    options.niri = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.niri.enable {
      home-manager.users.eulalia.home = {

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
