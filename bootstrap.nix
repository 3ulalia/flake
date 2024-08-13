/**
 */

{
  inputs,
  lib,
  ...
} : 
  let
    inherit (builtins) attrNames foldl' listToAttrs pathExists readDir trace; # TODO: why
    inherit (lib) filterAttrs removeSuffix;
    inherit (inputs.nixpkgs.lib) nixosSystem;

  helpers = {
    /**
      Given a list of attrsets, combines them into one attrset.

      list-to-attrs: [{...}] -> {...}

     */
    list-to-attrs = list: (foldl' (a: b: a // b) {} list);


    /**
      Given a list of attrsets, and a key present in each attrset, create an attrset mapping from
      the value of that key to the attrset itself.

      list-to-attrs-from-key :: string -> [{...}] -> {...}
     */
    list-to-attrs-from-key = field: list: listToAttrs (map (v: {name = v.${field}; value = v;}) list);
  };

  hosts = {
    /**
      Retrieves all valid hosts (really, just NixOS modules) at a given path.

      A "host" is defined as a folder with any name (conventionally, the host's hostname)
      that contains, at bare minimum, a `default.nix` file.

      get-hosts :: (path -> 'a) -> path -> ['a]

      get-hosts :: (host -> 'a) -> path -> ['a]
     */
    get-hosts = path: 
      let
	      valid-host-huh = (p: v: pathExists "${path}/${p}/default.nix"); # self-documenting
      in 
        map 
          (n: "${path}/${n}") 
          (attrNames
            (filterAttrs valid-host-huh 
              (filterAttrs (n: v: v == "directory") (readDir path))));

    /**
      Generates a system configuration from a given host. 

      This is mainly a wrapper around nixpkgs.lib.nixosSystem, but it uses special 
      attributes that are placed in the individual host file (by the user) to specify
      things like system architecture, hostname, and more.

      generate-system :: {modules: {...}; nixpkgs: {lib: {...}}; system: string; users = [string];} -> {...}

      generate-system :: host-configuration -> {hostname: system-configuration}
     */
    generate-system = modules: host-file: 
      { ${removeSuffix ".nix" (baseNameOf host-file)} = nixosSystem {
          modules = [
	          host-file
          ] ++ modules;
        };
      };
  };
  in
{
  generate-systems = path: modules: helpers.list-to-attrs (map (hosts.generate-system modules) (hosts.get-hosts path));
}