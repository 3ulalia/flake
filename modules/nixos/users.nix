{
  lib,
  pkgs,
  ...
} :
  let
    inherit (lib) mkOption types;
    inherit (lib.eula) mkOpt;
  in 
    mkOption { type = types.listOf (
      types.submodule {
        options = {
	  extraGroups = mkOpt (types.listOf types.str) [];
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
          shell = mkOpt types.package pkgs.zsh;
        };
      }
    );
    }
  
