{
  config,
  pkgs,
  lib,
  ...
}:
let

  conf = config.eula.modules.home-manager.desktop.apps.notif;
  configure-huh = (conf.pkg == pkgs.mako) && conf.opinionated && conf.enable;
in {
  # TODO: configure mako

  eula.modules.home-manager.desktop.apps.notif.type = lib.mkIf configure-huh "services";
  eula.modules.home-manager.desktop.spawn-at-startup = ["mako"];
}
