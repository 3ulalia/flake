{
  eulib,
  lib,
  ...
}: let
  inherit (lib) trace;
in {
  imports = map (n: ./. + ("/" + n)) (eulib.modules.nix-modules-in-dir [(/. + __curPos.file)] (trace "importing nixos modules folder" ./.));
}
