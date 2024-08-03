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
    inherit (builtins) readDir trace;
    inherit (nixpkgs.lib) nixosSystem;
    inherit (lib) attrNames filterAttrs pathExists;
    inherit (lib.eula) generateUsers;
  in {

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
        map fn (map (n: "${path}/${n}") (attrNames (filterAttrs valid-host-huh (filterAttrs (n: v: v == "directory") (readDir path)))));


    importHost = path: import path {inherit inputs lib;};

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
          inherit (host) system;
	  specialArgs = {inherit inputs outputs lib;};
          modules = [
            #( host )#// home-manager.nixosModules.home-manager )
	    ../hosts
          ];

          # TODO: handle sops-nix, etc here?

        };
      };
  }
