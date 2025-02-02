{ config, lib, osConfig, pkgs, ... } : 
let
  inherit (osConfig.eula.lib.options) mkOpt;
  inherit (lib) mkIf types;
  gccfg = config.eula.modules.home-manager.git-crypt;
in {
  options.eula.modules.home-manager.git-crypt = {
    enable = mkOpt types.bool false;
    secret-file = mkOpt (types.nullOr types.path) null; 
  };
  options.eula.secrets = mkOpt types.attrs {};
  config = mkIf gccfg.enable {
    home.packages = [pkgs.git-crypt];
    eula.secrets = (builtins.fromJSON (builtins.readFile
      (if (gccfg.secret-file == null) 
      then ../../users/${config.home.username}/secrets.json 
      else gccfg.secret-file)));
  };
}
