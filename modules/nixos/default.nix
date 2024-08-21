{
  bootstrap,
  lib,
  ...
} : 
  let
    inherit (lib) foldl' trace;
    inherit (lib.debug) traceSeq;

    map-list-to-attrs = list: foldl' (a: b: a // b) {} list;

    a = map (n: ./. + ("/" + n)) (bootstrap.modules.nix-modules-in-dir [__curPos.file] (trace "importing nixos modules folder" ./.));
  
  in {
    imports = traceSeq (trace "aaaaaaaaaaaaaaaaaaaaaaaa" a) a;
  }
