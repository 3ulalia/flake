{
  inputs,
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (lib) filter head split types mkIf trace mkAliasDefinitions;
  inherit (osConfig.eula.lib.helpers) list-to-attrs;
  mkOpt = osConfig.eula.lib.options.mkOpt;

  configs-to-enabled-settings = cfgs:
    list-to-attrs (map
      (n: {${config.eula.modules.home-manager.niri.${n}.pkg.pname}.enable = true;})
      (filter (n: config.eula.modules.home-manager.niri.${n}.enable) cfgs));
in {
  options.eula.modules.home-manager.niri = {
    enable = mkOpt types.bool false;
    pkg = mkOpt types.package pkgs.niri-stable;
  };

  config = mkIf config.eula.modules.home-manager.niri.enable {
    home = let
      opts = config.eula.modules.home-manager.niri;
    in {
      # home-manager settings

      # TODO break pkgs out into own modules

      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
    };

    programs.niri.package = config.eula.modules.home-manager.niri.pkg;
  };
}
