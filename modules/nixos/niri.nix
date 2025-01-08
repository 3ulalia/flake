{
  config,
  inputs,
  ...
}: let
  inherit (config.eula.lib.modules) any-user;
in {
  imports = [inputs.niri.nixosModules.niri];

  nixpkgs.overlays = [inputs.niri.overlays.niri];

  programs.niri.enable = any-user (user: user.eula.modules.home-manager.niri.enable) config.home-manager.users;

  home-manager.sharedModules = [
    ({
      osConfig,
      lib,
      ...
    }: {
      programs.niri.settings.debug = lib.mkIf (osConfig.networking.hostName == "the-end-of-all-things") {
        render-drm-device = "/dev/dri/renderD128";
      };
    })
  ];
}
