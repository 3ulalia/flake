{
  config,
  options,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkIf types;
  inherit (config.eula.lib.options) mkOpt;
in {
  options.eula.modules.nixos.bluetooth = {
    enable = mkOpt types.bool false;
  };

  config = mkIf config.eula.modules.nixos.bluetooth.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = mkDefault false;

    services.blueman.enable = mkDefault true;
  };
}
