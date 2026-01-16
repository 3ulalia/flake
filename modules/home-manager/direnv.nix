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
  cfg = config.eula.modules.home-manager.direnv;
in
{

  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  options.eula.modules.home-manager.direnv = {
    enable = mkOpt types.bool true;
    pkg = mkOpt types.package pkgs.direnv;
    nd-pkg = mkOpt types.package pkgs.nix-direnv;
    silent = mkOpt types.bool true;
    instant = mkOpt types.bool false;
    registry-name = mkOpt types.str "self";
  };
  config = mkIf cfg.enable {
    programs.direnv-instant.enable = cfg.instant;
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
        package = cfg.nd-pkg;
      };
      inherit (cfg) silent;
    };
    nix.registry = {
      ${cfg.registry-name}.flake = inputs.self;
    };
  };
}
