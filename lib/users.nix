{lib, ...}: let
  inherit (lib) listToAttrs mapAttrs mkDefault mkForce trace;

  /*
  *
  Given a username, import the corresponding user configuration file, and construct from that
  the corresponding user configuration to be stored in users.users.

  resolve-user :: {name: string; {...}} -> {...}

  resolve-user :: user -> user-configuration
  */
  resolve-user = name: user: let
    pass = null; # TODO sops
    _u = trace (user ? shell) user;
  in {
    home = mkDefault "/home/${name}";
    initialPassword = mkDefault (
      if pass == null
      then "${name}"
      else pass); # TODO sops
    isNormalUser = mkDefault true;
    createHome = mkDefault true;
    useDefaultShell = mkForce (!(user ? shell));
    shell =
      if (user ? shell)
      then user.shell
      else null;
    cryptHomeLuks = mkDefault null; # TODO luks

    extraGroups = mkDefault ((
        if user.privileged
        then ["wheel"]
        else []
      )
      ++ ["video" "input"]
      ++ user.extraGroups); # TODO mkDefault
  };

  /*
  *
  Given a username, import the corresponding user configuration file, and construct from that
  the corresponding home-manager configuration to be stored in home-manager.users.

  resolve-home :: {name: string; {...}} -> {...}

  resolve-home :: user -> home

  */
  resolve-home = extra-settings: name: user:
    {
      imports = [
        ../users/home.nix
        ../modules/home-manager
        ../users/${name}/home
      ];

      nixpkgs.config.allowUnfree = true;

      home = {
        homeDirectory = "/home/${name}";
        username = name;
        stateVersion = "23.11";
      };
    }
    // extra-settings;

  /*
  *
  Given a list of strings of usernames, returns an attrset from usernames to the configurations
  that result from evaluating their individual user configuration files.

  resolve-users :: [string] -> {string: {...}}
  */
  map-list-to-attrset = fn: users:
    listToAttrs (map (x: {
        name = x.name;
        value = fn x;
      })
      users);
in {
  config.eula.lib.users = {
    /*
      *
    Literally just a wrapper around resolve-users for consistent verbiage.

    TODO sig
    */
    generate-users = users: mapAttrs resolve-user users;

    generate-homes = extra-settings: users: mapAttrs (resolve-home extra-settings) users;
  };
}
