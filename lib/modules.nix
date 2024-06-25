/**
  Provides a series of helper functions for working with Nix modules.
 */

{
  lib,
  ...
} : 
  let
    inherit (builtins) attrNames baseNameOf dirOf pathExists readDir trace; # TODO: why
    inherit (lib) filterAttrs hasPrefix hasSuffix;
  in {
    /**
      Applies (maps) a function to each module located in a given folder path.

      This function does a lot of heavy lifting in the construction of this flake.
      The reason for this is that most operations when determining specific elements 
      to include can really be conceived of as mapping over a list of Nix modules.

      mapModules :: (path -> 'a) -> path -> ['a]
      
      mapModules :: (path -> module) -> path -> [module]
    */

    mapModules = fn: path: 
      let 

        /**
          Determines whether a given path is a valid Nix module path.
          
          This is true when either:
            * the path is to a single nix file, or
            * the path to a directory containing a `default.nix`

          valid-nix-module-huh :: path -> bool
         */
        valid-nix-module-huh = path: 
          let 
            file-name = trace path (baseNameOf path);
            file-type = (readDir (dirOf path))."${file-name}";
          in 
            # the path is to a single nix file
            ((file-type == "regular") && (hasSuffix file-name ".nix") && (!hasPrefix file-name "_")) ||
            # the path is to a directory containing a `default.nix`
            ((file-type == "directory") && pathExists (path + "/default.nix"));


        nix-modules-in-dir = filterAttrs (name: value: (valid-nix-module-huh (path + ("/" + name)))) (readDir path);
      in 
        map fn (attrNames nix-modules-in-dir);


    /**
      Applies (maps) a function to each module located in a given folder path,
      _including modules in subfolders_.
      
      mapModulesRec :: (path -> 'a) -> [path] -> ['a]
      */
    mapModulesRec = path: fn: 0; # cheating, for now
       
  }
