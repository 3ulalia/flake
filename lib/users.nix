{
  lib,
  pkgs,
  ...
} : 
  let 

    inherit (lib) listToAttrs mapAttrs;


    /**
      Given a username, import the corresponding user configuration file, and construct from that
      the corresponding user configuration to be stored in users.users.

      resolve-user :: {name: string; {...}} -> {...}

      resolve-user :: user -> user-configuration
     */
    resolve-user = user: 
      let 
        pass = null; # TODO sops
      in 
        {
          home = "/home/${user.name}";
          initialPassword = if pass == null then "${user.name}" else pass; # TODO sops TODO mkDefault
          isNormalUser = true; # TODO mkDefault
          createHome = true; # TODO mkDefault
          shell = user.shell; # TODO mkDefault
          cryptHomeLuks = null; # TODO mkDefault

          # NOTE: config.users.extraUserGroups has things we want to add to this,
          # but it's messy to require the entire system config for this function.
          # so instead we add it on after the fact at the call site and document.
          extraGroups = (if user.privileged then ["wheel"] else []) ++ ["video" "input"]; # TODO mkDefault
        };

    /**
      Given a username, import the corresponding user configuration file, and construct from that
      the corresponding home-manager configuration to be stored in home-manager.users.
      
      resolve-home :: string -> {...}

      resolve-home :: user -> home

       */
    resolve-home = user: 
      {

        imports = [
          ../users/home.nix
          ../users/${user.name}/packages.nix
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
    mapUsers = fn: path: 1;


    /**
      Given an existing user configuration and a list of groups to be added, combine the given list and the 
      existing list of extra groups for that user.

      TODO sig
     */
    patch-extra-groups = users: groups: mapAttrs (name: value: value // {extraGroups = groups ++ value.extraGroups;});

    /** 
      Literally just a wrapper around resolve-users for consistent verbiage.

      TODO sig
     */
    generate-users = users: map-list-to-attrset resolve-user users;

    generate-homes = users: map-list-to-attrset resolve-home users;


    }
