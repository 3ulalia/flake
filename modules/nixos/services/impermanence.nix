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

    imports = [inputs.impermanence.nixosModules.impermanence];

    options.eula.modules.services.impermanence = {
      enable = mkOpt types.bool false;
    };
    
    config = mkIf config.eula.modules.services.impermanence.enable {
      security.sudo.extraConfig = "Defaults lecture=never"; # avoid getting lectured on rollback
    };
  }
	      
