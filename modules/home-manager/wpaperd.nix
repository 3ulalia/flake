{
  bootstrap,
  config,
  osConfig,
  lib,
  pkgs,
  ...
} : let 
  inherit (osConfig.eula.lib.options) mkOpt;
  inherit (lib) mkIf types;

  wpaperd-config = config.eula.modules.home-manager.wpaperd;
in {

  options.eula.modules.home-manager.wpaperd = {
    enable = mkOpt types.bool false;
    path = mkOpt types.str "~/flake/artifacts/background.png";
    mode = mkOpt (types.enum ["fit" "fit-border-color" "center" "stretch" "tile"]) "fit";
  };

  config = mkIf wpaperd-config.enable {
    programs.wpaperd = {
      enable = true;
      settings = {
	default = {
          path = wpaperd-config.path;
	  mode = wpaperd-config.mode;
        };
      };
    };
  };
}
