{
  config,
  eulib,
  inputs,
  lib,
  ...
}: let
  inherit (eulib.modules) any-user;
in {
  config.nixpkgs.overlays = [inputs.eulalia-nvim.overlays.default];
}
