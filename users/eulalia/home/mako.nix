{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
} : {

    services.mako = {
      enable = true;
    };
}
