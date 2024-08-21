{
  config,
  lib,
  pkgs,
  ...
} :
  let
    inherit (lib) mapAttrs mkAliasDefinitions mkOption types;
    mkOpt = config.eula.lib.options.mkOpt;
  in { 
    options.eula.modules.nixos.users = mkOption { 
      type = types.attrsOf (
      types.submodule {
        options = {
	  extraGroups = mkOpt (types.listOf types.str) [];
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
          shell = mkOpt types.package pkgs.zsh;
	  home-config = mkOpt (types.attrsOf types.anything) {};
        };
      }
    );
  };
  
  config.home-manager = {
    users = mapAttrs (name: user: user.home-config) config.eula.modules.nixos.users;
  };
}
  
