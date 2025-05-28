{
  config,
  eulib,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf mkMerge mapAttrs trace types mkForce mapAttrsToList;
  inherit (eulib.modules) any-user;

  sops-users = lib.filterAttrs (n: v: v.eula.modules.home-manager.sops.enable) config.home-manager.users;
  sops-enable = any-user (user: user.eula.modules.home-manager.sops.enable) config.home-manager.users;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  config = mkMerge [
    {
      nix.extraOptions = ''
        plugin-files = ${pkgs.nix-plugins.overrideAttrs (o: {
          buildInputs = [pkgs.nixVersions.latest pkgs.boost];
          patches = (o.patches or []) ++ [./nix-plugins.patch];
        })}/lib/nix/plugins
      '';

      nix.settings.extra-builtins-file = [
        ../../../lib/secrets.nix
      ];
    }
    (mkIf sops-enable {
      /*

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
        defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";};
        # TODO: THIS IS INSECURE AND NEEDS TO BE CHANGED
        #age.sshKeyPaths = map (x: x + "/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED") (mapAttrsToList (x: y: config.users.users.${x}.home) sops-users);};
        /*
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
      */
    })
  ];
}
