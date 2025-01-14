/*
*
*/
{
  inputs,
  lib,
  ...
}: let
  inherit (builtins) attrNames elem foldl' listToAttrs pathExists readDir trace unsafeDiscardStringContext; # TODO: why
  inherit (lib) filterAttrs hasSuffix mkOption removeSuffix;
  inherit (inputs.nixpkgs.lib) nixosSystem;
in rec {
  helpers = rec {
    /*
    *
    Given a list of attrsets, combines them into one attrset.

    list-to-attrs: [{...}] -> {...}

    */
    list-to-attrs = list: (foldl' (a: b: a // b) {} list);

    /*
    *
    Given a list of attrsets, and a key present in each attrset, create an attrset mapping from
    the value of that key to the attrset itself.

    list-to-attrs-from-key :: string -> [{...}] -> {...}
    */
    list-to-attrs-from-key = field: list:
      listToAttrs (map (v: {
          name = v.${field};
          value = v;
        })
        list);
  };

  hosts = rec {
    /*
    *
    Retrieves all valid hosts (really, just NixOS modules) at a given path.

    A "host" is defined as a folder with any name (conventionally, the host's hostname)
    that contains, at bare minimum, a `default.nix` file.

    get-hosts :: (path -> 'a) -> path -> ['a]

    get-hosts :: (host -> 'a) -> path -> ['a]
    */
    get-hosts = path: let
      valid-host-huh = p: v: pathExists "${path}/${p}/default.nix"; # self-documenting
    in
      map
      (n: "${path}/${n}")
      (attrNames
        (filterAttrs valid-host-huh
          (filterAttrs (n: v: v == "directory") (readDir path))));

    hostfile-to-hostname = host-file: unsafeDiscardStringContext (removeSuffix ".nix" (baseNameOf host-file));

    /*
    *
    Generates a system configuration from a given host.

    This is mainly a wrapper around nixpkgs.lib.nixosSystem, but it uses special
    attributes that are placed in the individual host file (by the user) to specify
    things like system architecture, hostname, and more.

    generate-system :: {modules: {...}; nixpkgs: {lib: {...}}; system: string; users = [string];} -> {...}

    generate-system :: host-configuration -> {hostname: system-configuration}
    */
    generate-system = modules: special-args: host-file: {
      ${hostfile-to-hostname host-file} = nixosSystem {
        specialArgs = special-args;
        modules =
          [
            host-file
            {networking.hostName = lib.mkDefault (hostfile-to-hostname host-file);}
            {home-manager.extraSpecialArgs = special-args;}
          ]
          ++ modules;
      };
    };

    generate-systems = path: special-args: modules: helpers.list-to-attrs (map (hosts.generate-system modules special-args) (hosts.get-hosts path));
  };
  modules = rec {
    /*
        *
    Determines whether a given path is a valid Nix module path.

    This is true when either:
      * the path is to a single nix file, or
      * the path to a directory containing a `default.nix`

    valid-nix-module-huh :: path -> bool
    */
    valid-nix-module-huh = to-ignore: path: let
      file-name = baseNameOf path;
      file-type = (readDir (dirOf path))."${file-name}";
    in
      # the path is to a single nix file
      (((file-type == "regular") && (hasSuffix ".nix" file-name))
        ||
        # the path is to a directory containing a `default.nix`
        ((file-type == "directory") && pathExists "${path}/default.nix"))
      &&
      # the path is not to our recursion-preventing canary
      !(elem (toString path) to-ignore);

    nix-modules-in-dir = to-ignore: path: attrNames (filterAttrs (name: value: (valid-nix-module-huh to-ignore (path + "/${name}"))) (readDir path));
  };
  options = {
    mkOpt = type: default: mkOption {inherit type default;};

    mkOptd = type: default: description: mkOption {inherit type default description;};
  };
}
