{
  pkgs,
  ...
}: {
  config.eula.modules.home-manager.desktop = {
    apps.ctrl = {
      pkg = pkgs.avizo;
      enable = true;
      type = "services";
    };
    spawn-at-startup = ["avizo-service"];
  };
  config.services.avizo.settings = {
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
