{
  inputs,
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (lib) filter head split types mkIf trace mkAliasDefinitions;
  mkOpt = osConfig.eula.lib.options.mkOpt;
in {
  options.eula.modules.home-manager.niri = {
    enable = mkOpt types.bool false;
    pkg = mkOpt types.package pkgs.niri-stable;
  };

  config = mkIf config.eula.modules.home-manager.niri.enable {
    #nixpkgs.overlays = [inputs.niri.overlays.niri];
    home = {
      # home-manager settings
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
    };

    programs.niri.package = config.eula.modules.home-manager.niri.pkg;
  };
}
