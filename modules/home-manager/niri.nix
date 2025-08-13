{
  inputs,
  eulib,
  lib,
  pkgs,
  config,
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

    xdg.portal.config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
      "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
    };
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    eula.modules.home-manager.impermanence.directories = ["${lib.removePrefix (config.home.homeDirectory + "/") config.xdg.dataHome}/keyrings"];

    home = {
      # home-manager settings
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
    };

    nixpkgs.overlays = [inputs.niri.overlays.niri];

    #programs.niri.package = config.eula.modules.home-manager.niri.pkg;
    #programs.niri.enable = true;

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
