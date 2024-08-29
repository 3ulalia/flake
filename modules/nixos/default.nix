{
  bootstrap,
  lib,
  ...
} : 
  let
    inherit (lib) trace;
  in {
    imports = map (n: ./. + ("/" + n)) (bootstrap.modules.nix-modules-in-dir [__curPos.file] (trace "importing nixos modules folder" ./.));
  }
