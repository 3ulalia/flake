{
  config,
  lib,
  pkgs,
  ...
} : 
  let
    inherit (builtins) attrNames;
    inherit (lib) foldl' trace;

    map-list-to-attrs = list: foldl' (a: b: a // b) {} list;

  in {
    imports = attrNames (config.eula.lib.modules.nix-modules-in-dir __curPos.file ./.);
  }
