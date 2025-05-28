{
  config,
  eulib,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) length listToAttrs;
  inherit (lib) mkOption mkIf mkAliasDefinitions trace types;
  inherit (eulib.helpers) list-to-attrs;
  inherit (eulib.options) mkOpt;
in {
  imports = [inputs.disko.nixosModules.disko];

  options.eula.modules.services.disko = {
    enable = mkOpt types.bool false;
    disko-config = mkOption {type = types.path;};
    needed-for-boot = mkOpt (types.listOf types.str) [];
  };

  config = mkIf config.eula.modules.services.disko.enable {
    disko.devices = (import config.eula.modules.services.disko.disko-config).disko.devices;
    fileSystems = listToAttrs (map
      (item: {
        name = item;
        value = {neededForBoot = true;};
      })
      config.eula.modules.services.disko.needed-for-boot);
  };
}
