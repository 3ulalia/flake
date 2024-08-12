{
  lib,
  ...
} : 
  let 

    inherit (lib) listToAttrs mapAttrs mkDefault mkForce trace;


    /**
      Given a username, import the corresponding user configuration file, and construct from that
      the corresponding user configuration to be stored in users.users.

      resolve-user :: {name: string; {...}} -> {...}

      resolve-user :: user -> user-configuration
     */
    resolve-user = user: 
      let 
        pass = null; # TODO sops
	_u = trace (user ? shell) user;
      in 
        {
          home = mkDefault "/home/${user.name}";
          initialPassword = if pass == null then "${_u.name}" else pass; # TODO sops
          isNormalUser = mkDefault true;
          createHome = mkDefault true; 
          useDefaultShell = mkForce (!(user ? shell));
          shell = if (user ? shell) then user.shell else null;
          cryptHomeLuks = mkDefault null; # TODO luks

          # NOTE: config.users.extraUserGroups has things we want to add to this,
          # but it's messy to require the entire system config for this function.
          # so instead we include it as an argument.
          extraGroups = mkDefault ((if user.privileged then ["wheel"] else []) ++ ["video" "input"] ++ user.extraGroups); # TODO mkDefault
        };

    /**
      Given a username, import the corresponding user configuration file, and construct from that
      the corresponding home-manager configuration to be stored in home-manager.users.
      
      resolve-home :: {name: string; {...}} -> {...}

      resolve-home :: user -> home

       */
    resolve-home = user: 
      {
        imports = [
          ../users/home.nix
        ];

        home = {
          homeDirectory = "/home/${user.name}";
          username = user.name;
          stateVersion = "23.11";
        };
      };

    /**
      Given a list of strings of usernames, returns an attrset from usernames to the configurations
      that result from evaluating their individual user configuration files.

      resolve-users :: [string] -> {string: {...}}
     */
    map-list-to-attrset = fn: users: listToAttrs (map (x: {name = x.name; value = fn x;}) users);
  in {
    /** 
      Literally just a wrapper around resolve-users for consistent verbiage.

      TODO sig
     */
    generate-users = users: map-list-to-attrset resolve-user users;

    generate-homes = users: map-list-to-attrset resolve-home users;
  }
