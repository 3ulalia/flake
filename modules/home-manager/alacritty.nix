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

    options.eula.modules.home-manager.alacritty = {
      enable = mkOpt types.bool true;  
    };

    config = mkIf config.eula.modules.home-manager.alacritty.enable {
      home-manager.users.eulalia.home.packages = [pkgs.alacritty];
    };
  }
