{
  lib,
  ...
} : 
  let
    inherit (lib) foldl' mapAttrs mkOption types;

    inherit (lib.eula) mapModules;

    map-list-to-attrs = list: foldl' (a: b: a // b) {} list;

  in {
    options =  (mapModules import ./. __curPos.file);
  }
