{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
}: {
  # TODO: configure mako
  eula.modules.home-manager.desktop = {
    apps.notif = {
      pkg = pkgs.mako;
      enable = true;
      type = "services";
    };
    spawn-at-startup = ["mako"];
  };
}
