{
  lib,
  bootstrap,
  ...
}: let
  inherit (lib) foldl' trace;

  map-list-to-attrs = list: foldl' (a: b: a // b) {} list;
in {
  imports = map (n: ./. + ("/" + n)) (bootstrap.modules.nix-modules-in-dir [(/. + __curPos.file)] ./.);
}
