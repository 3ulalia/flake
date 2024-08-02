{
  config,
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

      resolve-user :: user -> home
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
      Given a list of strings of usernames, returns an attrset from usernames to the configurations
      that result from evaluating their individual user configuration files.

      resolve-users :: [string] -> {string: {...}}
     */
    resolve-users = users: listToAttrs (map (x: {name = x.name; value = resolve-user x;}) users);
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
    generateUsers = users: resolve-users users;
  }
