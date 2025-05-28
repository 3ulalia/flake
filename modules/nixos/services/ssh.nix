{
  config,
  eulib,
  lib,
  ...
}: let
  inherit (eulib.options) mkOpt;
  inherit (lib) mkIf types;
in {
  options.eula.modules.services.ssh = {
    enable = mkOpt types.bool false;
    port = mkOpt types.port 22;
  };

  config = mkIf config.eula.modules.services.ssh.enable {
    services.openssh = {
      enable = true;
      ports = [config.eula.modules.services.ssh.port];
      settings = {
        PasswordAuthentication = true; # TODO
        AllowUsers = null;
      };
    };

    networking.firewall.allowedTCPPorts = mkIf config.networking.firewall.enable [
      config.eula.modules.services.ssh.port
    ];
  };
}
