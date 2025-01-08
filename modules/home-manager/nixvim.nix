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

    imports = [inputs.nixvim.homeManagerModules.nixvim];

    options.eula.modules.home-manager.nixvim = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.eula.modules.home-manager.nixvim.enable {
      nixvim.enable = true;
      nixvim.defaultEditor = true;
    };
  }
