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

    options.eula.modules.home-manager.git = {
      enable = mkOpt types.bool true;  
      user-name = mkOpt types.str "user";
      user-email = mkOpt types.str "user@hostname";
    };

    config = mkIf config.eula.modules.home-manager.git.enable {
      programs.gh.enable = true;
      
      programs.git = {
	enable = true;
	userName = config.eula.modules.home-manager.git.user-name;
	userEmail = config.eula.modules.home-manager.git.user-email;
      };
    };
  }
