{
  config,
  eulib,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (eulib.options) mkOpt;
  cfg = config.eula.modules.home-manager.tmux;
in
{

  options.eula.modules.home-manager.tmux = {
    enable = mkOpt types.bool true;
    pkg = mkOpt types.package pkgs.tmux;
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
    };
  };
}
