{
  pkgs,
  lib,
  config,
  ...
}: 
let
  conf = config.eula.modules.home-manager.desktop.apps.ctrl;
  configure-huh = (conf.pkg == pkgs.avizo) && conf.opinionated && conf.enable;
in {

  config.eula.modules.home-manager.desktop.apps.ctrl.type = lib.mkIf configure-huh "services";
  config.eula.modules.home-manager.desktop.spawn-at-startup = ["avizo-service"];

  config.services.avizo.settings = lib.mkIf configure-huh {
    default = {
      time = 2;
      padding = 10;
      width = 256;
      height = 128;
      background = "rgba(160,160,160,0.5)";
      y-offset = 0.75;
    };
  };
}
