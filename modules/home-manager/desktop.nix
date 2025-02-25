{ config, inputs, pkgs, lib, osConfig, ...}: let
  inherit (osConfig.eula.lib.options) mkOpt;
  inherit (lib) filterAttrs mapAttrs' mapAttrsToList mkDefault types;
  mkPkgOpt = en: pkg: type: {
    enable = mkOpt types.bool en;
    pkg = mkOpt types.package pkg;
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
    launcher = mkPkgOpt true pkgs.fuzzel "programs";
    bg = mkPkgOpt true pkgs.wpaperd "programs"; # TODO: migrate :p
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
  };

  config = 
    let
      enablePackages = t:
        mapAttrs' 
          (n: v: lib.nameValuePair
            v.pkg.pname
            {enable = mkDefault v.enable;}
          )
          (filterd desktop t);
    in {
    home.packages = mapAttrsToList 
      (n: v: v.pkg)
      (filterd desktop "packages");
    programs = enablePackages "programs"; 
    services = enablePackages "services";
  };
}
