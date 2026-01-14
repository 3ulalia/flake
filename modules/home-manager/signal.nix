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
  cfg = config.eula.modules.home-manager.signal;
in {
  options.eula.modules.home-manager.signal= {
    enable = mkOpt types.bool true;
    pkg = mkOpt types.package pkgs.signal-desktop;
  };
  config = mkIf cfg.enable {
    home = {
      packages = [cfg.pkg];
    };
    eula.modules.home-manager.desktop.spawn-at-startup = ["signal-desktop"];
  };
}
