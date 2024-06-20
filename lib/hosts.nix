/**
  Provides a series of helper functions for working with host configurations.
 */

{
  lib,
  ...
} : 
  let
    inherit (lib) attrVals filterAttrs pathExists readDir;
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
        valid-host-huh = path: pathExists "${path}/configuration.nix"; # self-documenting
      in 
        map fn (attrVals (filterAttrs valid-host-huh (filterAttrs (n: v: v == "directory") (readDir path))));


    /**
      Generates a system configuration from a given host. 

      This is mainly a wrapper around nixpkgs.lib.nixosSystem, but it uses special 
      attributes that are placed in the individual host file (by the user) to specify
      things like system architecture, hostname, and more.

      generate-system :: {modules: {...}; nixpkgs: {lib: {...}}; system: string; users = [string];} -> {...}

      generate-system :: host-configuration -> {hostname: system-configuration}
     */
    generateSystem = host:
      let 
        host-pkgs = host.nixpkgs;
      in 
        host-pkgs.lib.nixosSystem {
          inherit (host) modules system;

          users.users = generateUsers host.users;

          # TODO: handle home-manager, sops-nix, etc here?

        } // {inherit (host) hostname}; # add this key so we can use it to convert into an attrset later


  }