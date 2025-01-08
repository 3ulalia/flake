{
  bootstrap,
  lib,
  ...
}: let
  inherit (lib) trace;
  nmid = bootstrap.modules.nix-modules-in-dir [__curPos.file] (trace "importing callbacks folder" ./.);
in {
  imports = map (n: ./. + ("/" + n)) (trace nmid nmid);
}
