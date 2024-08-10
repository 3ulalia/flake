{
  lib,
  niri,
  pkgs,
  inputs,
  ...
} : 
  let 

  inherit (lib) types mkIf;
  inherit (lib.eula) mkOpt;

  in {

    imports = [niri.nixosModules.niri];

    options.niri = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf inputs.niri.enable {
      home = {
        packages = with pkgs; [
          yofi
          swww
          mako
        ];
      };

      programs.niri.enable = true;


    };
  }