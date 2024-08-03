/**
  Provides a series of helper functions for working with Nix modules.
 */

{
  lib,
  ...
} : 
  let
    inherit (builtins) attrNames baseNameOf dirOf pathExists readDir trace toString; # TODO: why
    inherit (lib) filterAttrs hasSuffix;
  in {
    /**
      Applies (maps) a function to each module located in a given folder path.

      This function does a lot of heavy lifting in the construction of this flake.
      The reason for this is that most operations when determining specific elements 
      to include can really be conceived of as mapping over a list of Nix modules.

      mapModules :: (path -> 'a) -> path -> path -> ['a]
      
      mapModules :: (path -> module) -> path -> path -> [module]
    */

    mapModules = fn: path: toIgnore: 
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
	          pth = trace ("path: " + (toString path) + " toIgnore: ${toIgnore}") path; 
            file-name = trace (baseNameOf pth) (baseNameOf pth);
            file-type = trace (readDir (dirOf path))."${file-name}" (readDir (dirOf path))."${file-name}";
          in 
            # the path is to a single nix file
            (((file-type == "regular") && (hasSuffix ".nix" file-name)) ||
            # the path is to a directory containing a `default.nix`
            ((file-type == "directory") && pathExists ("${path}/default.nix"))) && 
            # the path is not to our recursion-preventing canary
            ((toString path) != "${toIgnore}");

        nix-modules-in-dir = filterAttrs (name: value: (valid-nix-module-huh (path + "/${name}"))) (readDir path);

        nmid = trace nix-modules-in-dir nix-modules-in-dir;

        _unused = trace "reached end of let in mapmodules" 1;

        _one = _unused;
      in 
        map fn (map (name: path + "/${if _one != 0 then name else name}") (attrNames nmid));

  }
