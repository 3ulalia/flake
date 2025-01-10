{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
}: {
  # TODO: configure mako
  eula.modules.home-manager.desktop.notif = {
    pkg = pkgs.mako;
    enable = true;
    type = "services";
  };
}
