{
  config,
  eulib,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (eulib.modules) any-user; # TODO?
  enable-direnv = any-user (user: user.eula.modules.home-manager.direnv.enable) config.home-manager.users;
in {
  nix.registry = mkIf enable-direnv {
    self.flake = inputs.self;
  };
}
