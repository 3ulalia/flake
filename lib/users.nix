{
  lib,
  pkgs,
  ...
} : 
  let 

    inherit (lib) listToAttrs;


    /**
      Given a username, import the corresponding user configuration file, and construct from that
      the corresponding home-manager config.

      resolve-user :: string -> {...}
     */
    resolve-user = user: 
      let 
        user-level-config = import ../users/${user} {inherit pkgs;};
      in 
        {
          home = {
            username = user;
            homeDirectory = "/home/${user}";
            packages = user-level-config.packages;
            stateVersion = "24.05";

          };

          programs.home-manager.enable = true;
        };


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
