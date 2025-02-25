{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config.eula.lib.modules) any-user;
in {

  imports = [inputs.niri.nixosModules.niri];

  programs.niri.enable = any-user (user: user.eula.modules.home-manager.niri.enable) config.home-manager.users;

  nixpkgs.overlays = [inputs.niri.overlays.niri];
  
  home-manager.sharedModules = [
    ({
      osConfig,
      lib,
      ...
    }: {
      programs.niri.settings.debug = lib.mkIf (osConfig.networking.hostName == "the-end-of-all-things") {
        render-drm-device = "/dev/dri/renderD128";
      };
      programs.niri.settings.outputs."eDP-1" = lib.mkIf (osConfig.networking.hostName == "catalina") {
        scale = 1.5;
      };
    })
  ];
}
