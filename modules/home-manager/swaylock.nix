{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
} : {
    options.eula.modules.home-manager.swaylock-effects.spawn-command = lib.mkOption {type=lib.types.listOf lib.types.str; default=[""];};
}
