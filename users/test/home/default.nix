{
  eulib,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = map (n: ./. + ("/" + n)) (eulib.modules.nix-modules-in-dir [(/. + __curPos.file)] ./.);
}
