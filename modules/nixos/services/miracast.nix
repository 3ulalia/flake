{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.eula.lib.options) mkOpt;
  inherit (lib) mkIf types;
in {
  options.eula.modules.services.miracast = {
    enable = mkOpt types.bool false;
  };

  config = mkIf config.eula.modules.services.miracast.enable {
    environment.systemPackages = [pkgs.gnome-network-displays];
    networking.firewall = mkIf config.networking.firewall.enable {
      allowedTCPPorts = [7236 7250];
      allowedUDPPorts = [7236 5353];
    };
  };
}
