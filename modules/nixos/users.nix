{
  config,
  lib,
  pkgs,
  ...
} :
  let
    inherit (lib) mkOption types;
    mkOpt = config.eula.lib.options.mkOpt;
  in { 
    options.eula.modules.nixos.users = mkOption { 
      type = types.listOf (
      types.submodule {
        options = {
	  extraGroups = mkOpt (types.listOf types.str) [];
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
          shell = mkOpt types.package pkgs.zsh;
        };
      }
    );
    };}
  
