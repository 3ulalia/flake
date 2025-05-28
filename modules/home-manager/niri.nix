{
  inputs,
  eulib,
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (lib) filter head splitString types mkIf trace mkAliasDefinitions;
  mkOpt = eulib.options.mkOpt;
  desktop-cfg = config.eula.modules.home-manager.desktop;
in {
  options.eula.modules.home-manager.niri = {
    enable = mkOpt types.bool false;
    pkg = mkOpt types.package pkgs.niri-stable;
  };

  config = mkIf config.eula.modules.home-manager.niri.enable {
    home = {
      # home-manager settings
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
    };

    programs.niri.package = config.eula.modules.home-manager.niri.pkg;

    programs.niri.settings = {
      spawn-at-startup = map (cmd: {command = splitString " " cmd;}) desktop-cfg.spawn-at-startup;
      input.touchpad = {
        accel-speed = desktop-cfg.pointer.touchpad.speed;
        accel-profile = desktop-cfg.pointer.touchpad.profile;
        dwt = desktop-cfg.pointer.touchpad.disable-while-typing;
        click-method = desktop-cfg.pointer.touchpad.click-method;
      };

      switch-events = lib.mapAttrs (n: v: {action.spawn = splitString " " v;}) (lib.filterAttrs (n: v: v != null) desktop-cfg.switches);
    };
  };
}
