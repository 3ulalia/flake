/**
 */

{
  inputs,
  lib,
  outputs,
  ...
} : 
  let
    inherit (builtins) attrNames baseNameOf dirOf elemAt findFirst foldl' listToAttrs matchAttrs pathExists readDir trace toString; # TODO: why
    inherit (lib) filterAttrs hasSuffix;
  in {

    modules = rec {

    /**
      Determines whether a given path is a valid Nix module path.
      
      This is true when either:
        * the path is to a single nix file, or
        * the path to a directory containing a `default.nix`

      valid-nix-module-huh :: path -> bool
      */
    valid-nix-module-huh = to-ignore: path: 
      let
        pth = trace ("path: " + (toString path) + " toIgnore: ${to-ignore}") path; 
        file-name = trace (baseNameOf pth) (baseNameOf pth);
        file-type = trace (readDir (dirOf path))."${file-name}" (readDir (dirOf path))."${file-name}";
      in 
        # the path is to a single nix file
        (((file-type == "regular") && (hasSuffix ".nix" file-name)) ||
        # the path is to a directory containing a `default.nix`
        ((file-type == "directory") && pathExists ("${path}/default.nix"))) && 
        # the path is not to our recursion-preventing canary
        ((toString path) != "${to-ignore}");


    nix-modules-in-dir = to-ignore: path: filterAttrs (name: value: (valid-nix-module-huh to-ignore (path + "/${name}"))) (readDir path);


    /**
      Applies (maps) a function to each module located in a given folder path.

      This function does a lot of heavy lifting in the construction of this flake.
      The reason for this is that most operations when determining specific elements 
      to include can really be conceived of as mapping over a list of Nix modules.

      mapModules :: (path -> 'a) -> path -> path -> ['a]
      
      mapModules :: (path -> module) -> path -> path -> [module]
    */

    mapModules = to-ignore: fn: path: 
      let 
        nmid = nix-modules-in-dir to-ignore path;
      in 
        map fn (map (name: path + "/${name}") (attrNames nmid));

    };
  helpers = rec {
    /**
      Given an input pattern (taken as an attrset) and a list of lists of attribute-result pairs, determines the appropriate result.
      Returns `null` if no result can be found.

      example: 

      match { platform = "linux"; arch = "aarch64"; } [
            [ { platform = "darwin"; } "it's macOS" ]         
            [ { platform = "linux"; } "it's Linux" ]
          ]
      => "it's Linux"

      kudos to iFreilicht on the NixOS Discourse for writing this!

      match :: {...} -> [[{...} 'a]] -> Option<'a>
     */
    
    match = v: l: elemAt (
      findFirst (
        x: (if_let v (elemAt x 0)) != null
      ) null l
    ) 1;

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
    
    /**
      Given an input pattern (taken as an attrset) and an attrset, determines if the given pattern
      is contained within the given attrset. Returns the given attrset if it is, and null if it isn't.

      example:

      if_let { platform = "darwin"; arch = "aarch64"; } { platform = "darwin"; }
      => { arch = "aarch64"; platform = "darwin"; }

      if_let { platform = "darwin"; arch = "aarch64"; } { platform = "linux"; }  
      => null

      if_let :: {...} -> {...} -> Option<{...}>
     */
    if_let = attrs: pattern: if matchAttrs pattern attrs then attrs else null;
 
  };

  hosts = 
  with inputs;

  let
    inherit (builtins) readDir foldl' trace;
    inherit (nixpkgs.lib) nixosSystem;
    inherit (lib) attrNames filterAttrs pathExists;

    concat-list = list: foldl' (x: y: x + " " + y) "" list;

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
	    ./hosts
	    host
          ];
        };
      };
  };}
