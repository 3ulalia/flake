{
  lib,
  ...
} : 
  let 

    inherit (lib) listToAttrs;

    resolve-user = user: import "./users/${user}";


    /**
      Given a list of strings of usernames, returns an attrset from usernames to the configurations
      that result from evaluating their individual user configuration files.

      resolve-users :: [string] -> {string: {...}}
     */
    resolve-users = users: listToAttrs (map (x: {name = x; value = resolve-user x;}) users);
  in {
    mapUsers = fn: path: 1;

    generateUsers = users: 
      let 
        resolved-users = resolve-users users;
      in
        resolved-users;

  }