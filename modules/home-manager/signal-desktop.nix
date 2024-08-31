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

    options.eula.modules.home-manager.vesktop= {
      enable = mkOpt types.bool false;  
    };

    config = mkIf config.eula.modules.home-manager.vesktop.enable {

      home.packages = [pkgs.vesktop];

    };
  }
