{
  config,
  eulib,
  lib,
  ...
}: let
  inherit (lib) mkIf trace types;
  inherit (eulib.options) mkOpt;
in {
  options.eula.modules.services.ly.enable = mkOpt types.bool false;

  config = mkIf config.eula.modules.services.ly.enable {
    services.displayManager.ly.enable = trace "ly is enabled systemwide!" true;
    systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
  };
}
