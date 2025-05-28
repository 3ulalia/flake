{
  eulib,
  lib,
  ...
}: let
  inherit (lib) trace;
  nmid = eulib.modules.nix-modules-in-dir [(/. + __curPos.file)] (trace "importing callbacks folder" ./.);
in {
  imports = map (n: ./. + ("/" + n)) (trace nmid nmid);
}
