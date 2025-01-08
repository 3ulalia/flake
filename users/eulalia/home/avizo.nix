{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
} : {

  config.services.avizo.settings = {
    default = {
      padding = 10;
    };
  }
}
