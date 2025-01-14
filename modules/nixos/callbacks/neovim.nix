{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config.eula.lib.modules) any-user;
in {
  config.nixpkgs.overlays = [ inputs.eulalia-nvim.overlays.default ];
}
