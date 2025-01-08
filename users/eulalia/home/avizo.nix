{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
}: {
  config.services.avizo.settings = {
    default = {
      time = 2;
      padding = 10;
      width = 256;
      height = 128;
      background = "rgba(160,160,160,0.5)";
    };
  };
}
