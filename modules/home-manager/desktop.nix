{ config, inputs, pkgs, lib, osConfig, ...}: let
  inherit (osConfig.eula.lib.options) mkOpt;
  inherit (lib) filterAttrs mapAttrs' mapAttrsToList mkDefault types;
  mkPkgOpt = en: pkg: type: {
    enable = mkOpt types.bool (mkDefault en);
    pkg = mkOpt types.package (mkDefault pkg);
    type = mkOpt (types.enum ["programs" "services" "packages"]) type;
  };
  desktop = config.eula.modules.home-manager.desktop;
  filterd = a: t: filterAttrs (n: v: v.type == t) a;
in {
  /** 
    Adding a package to this option means that it
    _will_ be available to any programs that want
    to access them. It does _not_ guarantee that 
    they will be configured; that is left to the 
    individual modules belonging to the user.
  */
  options.eula.modules.home-manager.desktop = {
    apps = mkOpt (types.submodule {options = {
      launcher = mkPkgOpt true pkgs.fuzzel "programs";
      bg = mkPkgOpt true pkgs.wpaperd "services";
      notif = mkPkgOpt true pkgs.mako "services";
      ctrl = mkPkgOpt true pkgs.avizo "services";
      bar = mkPkgOpt true pkgs.waybar "programs";
      brightness = mkPkgOpt true pkgs.brightnessctl "packages"; # TODO: pkgs.wluma
      night-shift = mkPkgOpt false pkgs.gammastep "services"; # TODO: pkgs.wlsunset
      locker = mkPkgOpt false pkgs.swaylock "programs";
      idle = mkPkgOpt false pkgs.swayidle "services";
      clip = mkPkgOpt true pkgs.wl-clipboard "packages";
      term = mkPkgOpt true pkgs.alacritty "programs";
      browser = mkPkgOpt true pkgs.firefox "programs";
    };}) {};

    spawn-at-startup = mkOpt (types.listOf types.str) [];

    switches = mkOpt (types.submodule { options = {
      lid-close = mkOpt (types.nullOr types.str) "systemctl suspend";
      lid-open = mkOpt (types.nullOr types.str) null;
    };}) {};

    pointer = mkOpt (types.submodule {options = {
      cursor = mkOpt (types.submodule { options = {
        pkg = mkOpt types.package pkgs.rose-pine-cursor;
        name = mkOpt types.str "BreezeX-RosePine-Linux";
        size = mkOpt types.int 32;
        compat = mkOpt types.bool true;
      };}) {};
      touchpad = mkOpt (types.submodule {options = {
        speed = mkOpt types.float 1.000;
        profile = mkOpt (types.enum ["adaptive" "flat"]) "adaptive";
        disable-while-typing = mkOpt types.bool false;
        click-method = mkOpt (types.enum ["button-areas" "clickfinger"]) "clickfinger";
      };}) {};
    };}) {};
  };

  config = 
    let
      ptr-cfg = desktop.pointer;
      cursor-cfg = ptr-cfg.cursor;
      enablePackages = t:
        mapAttrs' 
          (n: v: lib.nameValuePair
            v.pkg.pname
            {enable = mkDefault v.enable;}
          )
          (filterd desktop.apps t);
    in {
    home.packages = mapAttrsToList 
      (n: v: v.pkg)
      (filterd desktop.apps "packages");
    programs = enablePackages "programs"; 
    services = (enablePackages "services")
    // {mpris-proxy.enable = true;};

    home.pointerCursor = {
      gtk.enable = cursor-cfg.compat;
      x11.enable = cursor-cfg.compat;
      package = cursor-cfg.pkg;
      name = cursor-cfg.name;
      size = cursor-cfg.size;
    };
  };
}
