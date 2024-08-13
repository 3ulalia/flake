/**
  Provides a series of helper functions for working with host configurations.
 */

{
  lib,
  inputs,
  outputs,
  ...
} : 

  with inputs;

  let
    inherit (builtins) readDir foldl' trace;
    inherit (nixpkgs.lib) nixosSystem;
    inherit (lib) attrNames filterAttrs pathExists;

    concat-list = list: foldl' (x: y: x + " " + y) "" list;

  in {
    eula.lib.hosts = {
    /**
      Applies a given function to each host in a given folder.

      A "host" is defined as a folder with any name (conventionally, the host's hostname)
      that contains, at bare minimum, a `configuration.nix` file.

      mapHosts :: (path -> 'a) -> path -> ['a]

      mapHosts :: (host -> 'a) -> path -> ['a]
     */
    mapHosts = fn: path: 
      let
        _u = trace "mapHosts called: ${path}" path;
	valid-host-huh = (p: v: pathExists "${_u}/${p}/default.nix"); # self-documenting
      in 
        map (a: trace "mapping some function onto ${a} in mapHosts call over ${path}" (fn a)) (let b = (map (n: "${path}/${n}") (let a = attrNames (filterAttrs valid-host-huh (filterAttrs (n: v: v == "directory") (readDir path))); in trace "valid entries to be mapped as hosts in ${path}: ${concat-list a}" a)); in trace "mapped over the valid entries to generate these paths: ${concat-list b}" b);


    importHost = path: import (trace "importing host: ${path}" path) {inherit inputs lib;};

    /**
      Generates a system configuration from a given host. 

      This is mainly a wrapper around nixpkgs.lib.nixosSystem, but it uses special 
      attributes that are placed in the individual host file (by the user) to specify
      things like system architecture, hostname, and more.

      generate-system :: {modules: {...}; nixpkgs: {lib: {...}}; system: string; users = [string];} -> {...}

      generate-system :: host-configuration -> {hostname: system-configuration}
     */
    generateSystem = host:
	{ ${host.networking.hostName} = nixosSystem {
          modules = [
	    ../hosts
	    host
          ];
        };
      };
  };}
