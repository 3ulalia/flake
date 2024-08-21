{
  config,
  inputs,
  lib,
  pkgs,
  ...
} : 
  let 
    inherit (builtins) length;
    inherit (lib) mkOption mkIf mkAliasDefinitions trace types;
    inherit (config.eula.lib.helpers) list-to-attrs;
    inherit (config.eula.lib.options) mkOpt;
  in {

    imports = [(trace "importing niri nixos module" inputs.niri.nixosModules.niri)];

    options.eula.modules.nixos.niri.enableFor = mkOpt (types.listOf types.str) [];
    
    config = mkIf ((length config.eula.modules.nixos.niri.enableFor) != 0) rec {
      programs.niri.enable = (trace "niri is enabled systemwide!" true);
      
      home-manager.users = 
	list-to-attrs (
	  map 
	    (name: {${name} = {config.eula.modules.home-manager.niri.enable = true;};})
	    (trace "mapping over users to enable niri accordingly!" config.eula.modules.nixos.niri.enableFor)
	);
    };
}
	      
