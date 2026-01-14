{
  config,
  eulib,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (eulib.modules) any-user; # TODO?
  enable-lowbatt = any-user (user: user.eula.modules.home-manager.services.lowbatt.enable) config.home-manager.users;
  lowbatt-script = pkgs.writeShellApplication {
    name = "lowbatt-script";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
    text = ''
      for i in $(ps -eo user,uid | awk 'NR>1 && $2 >= 1000 && ++seen[$2]==1{print $1}'); do # only for logged-in users
        notify-send "" "" --replace-id "$(cat /home/"$i"/.local/state/lbnotif)" --expire-time 1 --transient;
      done
    '';
  };
in {
  services.udev.extraRules = mkIf enable-lowbatt ''
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", ENV{POWER_SUPPLY_TYPE}=="Mains", RUN+="${lowbatt-script}/bin/lowbatt-script"
  '';
}
