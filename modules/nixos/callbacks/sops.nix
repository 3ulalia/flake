{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf mapAttrs trace types;
  inherit (config.eula.lib.options) mkOpt;

  sops-users = lib.filterAttrs (n: v: v.eula.modules.home-manager.sops.enable) config.home-manager.users;
  sops-enable = (lib.length (builtins.attrNames sops-users)) != 0;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  options.eula.modules.services.sops = {
    enable = mkOpt types.bool false;
  };

  config = mkIf sops-enable {
    users.users = lib.foldl' 
      (x: y: x // y) 
      {} 
      (map 
        (x: {${x}.hashedPasswordFile = config.sops.secrets."passwords/${x}".path;})
        (builtins.attrNames sops-users));

    sops = {
      defaultSopsFile = "secrets/secrets.yaml";
    };
  };
}
