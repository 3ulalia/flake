{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf mapAttrs trace types mkForce mapAttrsToList;
  inherit (config.eula.lib.options) mkOpt;

  sops-users = lib.filterAttrs (n: v: v.eula.modules.home-manager.sops.enable) config.home-manager.users;
  sops-enable = false;#(lib.length (builtins.attrNames sops-users)) != 0;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  config = mkIf sops-enable {
    users.users = lib.foldl' 
      (x: y: x // y) 
      {} 
      (map 
        (x: {${x} = {
          hashedPasswordFile = config.sops.secrets."passwords/${x}".path;
          initialPassword = mkForce null;
        };})
        (builtins.attrNames sops-users));

    sops = {
      defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";
      # TODO: THIS IS INSECURE AND NEEDS TO BE CHANGED
      age.sshKeyPaths = map (x: x + "/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED") (mapAttrsToList (x: y: config.users.users.${x}.home) sops-users);
      secrets = builtins.foldl'
        (x: y: x // y)
        {}
        (map
          (x: {"passwords/${x}".neededForUsers = true;})
          (mapAttrsToList
            (n: v: v.home.username)
            sops-users
          )
        );
    };

  };
}
