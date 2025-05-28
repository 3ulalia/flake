{
  config,
  eulib,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (eulib.options) mkOpt;
  cfg = config.eula.modules.home-manager.discord;
in {
  options.eula.modules.home-manager.discord = {
    enable = mkOpt types.bool false;
    pkg = mkOpt types.package pkgs.vesktop;
  };
  config = mkIf cfg.enable {
    home = {
      packages = [cfg.pkg];
    };
    eula.modules.home-manager.impermanence.directories = [".config/vesktop"];
  };
}
