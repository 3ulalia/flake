{
  config,
  lib,
  ...
}: let
  inherit (config.eula.lib.modules) any-user;
  lockers = lib.mapAttrs
    (_: user: {${user.eula.modules.home-manager.desktop.locker.pkg.pname} = {};})
    config.home-manager.users;
in {
  config.security.pam.services = lib.foldl' (x: y: x//y) {} (lib.attrValues lockers);
}
