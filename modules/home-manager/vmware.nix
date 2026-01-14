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
  cfg = config.eula.modules.home-manager.vmware;
in {
  options.eula.modules.home-manager.vmware = {
    enable = mkOpt types.bool false;
    pkgs = mkOpt (types.listOf types.package) [pkgs.openconnect pkgs.gp-saml-gui];
  };
  config = mkIf cfg.enable {
    home = {
      packages = cfg.pkgs;
      shellAliases = {
        univpn = "gp-saml-gui -S";
      };
    };
  };
}
