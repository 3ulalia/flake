{
  bootstrap,
  lib,
  ...
} : 
  let
    inherit (lib) foldl' trace;

    map-list-to-attrs = list: foldl' (a: b: a // b) {} list;

  in {
    imports = bootstrap.modules.nix-modules-in-dir __curPos.file ./.;
  }
