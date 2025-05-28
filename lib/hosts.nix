/*
*
Provides a series of helper functions for working with host configurations.
*/
{
  lib,
  ...
}:
let
  inherit (builtins) readDir unsafeDiscardStringContext;
  #inherit (nixpkgs.lib) nixosSystem;
  inherit (lib) attrNames filterAttrs foldl' nixosSystem pathExists removeSuffix;
in rec {
  /*
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

  generate-systems = path: special-args: modules: foldl' (a: b: a // b) {} (map (generate-system modules special-args) (get-hosts path));
}

