{
  config,
  eulib,
  lib,
  pkgs,
  ...
} : 
let
  inherit (lib) mkIf types;
  inherit (eulib.options) mkOpt;
  cfg = config.eula.modules.home-manager.mc;
in {
  options.eula.modules.home-manager.mc = {
    enable = mkOpt types.bool false;
    pkg = mkOpt types.package pkgs.prismlauncher;
  };
  config = mkIf cfg.enable {
    home = {
      packages = [cfg.pkg];
    };
    eula.modules.home-manager.impermanence.directories = [".local/share/PrismLauncher"];
  };
}
