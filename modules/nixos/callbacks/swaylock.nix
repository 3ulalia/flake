{
  config,
  lib,
  ...
}: let
  inherit (lib) trace mkIf;
  inherit (config.eula.lib.modules) any-user;
in {
  config = mkIf (any-user (user: user.programs.swaylock.enable) config.home-manager.users) {
    security.pam.services.swaylock = {};
  };
}
