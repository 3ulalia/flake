{
  lib,
  ...
} : 
  let
    inherit (lib) foldl' mapAttrs mkOption types;

    inherit (lib.eula) mapModules;

    map-list-to-attrs = list: foldl' (a: b: a // b) {} list;

  in {
    options = map-list-to-attrs (mapModules (a: {${a} = import a;}) ./. __curPos.file);
  }
