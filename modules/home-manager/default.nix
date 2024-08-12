{
  lib,
  ...
} : 
  let
    inherit (builtins) baseNameOf;
    inherit (lib) foldl' mapAttrs mkOption trace types removeSuffix;

    inherit (lib.eula) mapModules;

    map-list-to-attrs = list: foldl' (a: b: a // b) {} list;

    a = map-list-to-attrs (mapModules (a: {${removeSuffix ".nix" (baseNameOf a)} = import a;}) ./. __curPos.file);
 
  in {
  options.modules = trace a a;

 }
