{
  config,
  eulib,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (eulib.modules) any-user;
in {
  imports = [inputs.niri.nixosModules.niri];

  programs.niri.enable = (any-user (user: user.eula.modules.home-manager.niri.enable) config.home-manager.users);
  programs.niri.package = lib.mkDefault pkgs.niri-unstable;

  nixpkgs.overlays = [inputs.niri.overlays.niri];

  home-manager.sharedModules = [
    ({
      osConfig,
      lib,
      ...
    }: lib.mkMerge  [

      (lib.mkIf (osConfig.networking.hostName == "the-end-of-all-things") {
        programs.niri.settings.debug = {
          render-drm-device = "/dev/dri/renderD128";
        };
      })
      
      (lib.mkIf (osConfig.networking.hostName == "catalina") { 
        programs.niri.settings.outputs."eDP-1" = {
          scale = 1.5;
        };
      })
    ])
  ];
}
