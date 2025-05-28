{
  config,
  eulib,
  inputs,
  lib,
  ...
}: let
  inherit (eulib.modules) any-user; # TODO?
in {
  config.nixpkgs.overlays = [inputs.eulalia-nvim.overlays.default];
}
