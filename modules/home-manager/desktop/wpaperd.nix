{
  config,
  pkgs,
  lib,
  ...
}: 

let

  conf = config.eula.modules.home-manager.desktop.apps.bg;
  configure-huh = (conf.pkg == pkgs.wpaperd) && conf.opinionated && conf.enable;

in {

  config.eula.modules.home-manager.desktop.apps.bg.type = lib.mkIf configure-huh "services";

  config.services.wpaperd = lib.mkIf configure-huh {
    settings = {
      default = {
        mode = "center";
        duration = "24h";
        path = ../../../artifacts/quiet-victories/backgrounds;
      };
    };
  };
}
