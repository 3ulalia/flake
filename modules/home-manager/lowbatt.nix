{
  config,
  lib,
  eulib,
  pkgs,
  ...
}: let
  notify = 10;
  critical = 5;
  device = "BAT0";
  lbnotif = "${config.xdg.stateHome}/lbnotif";
  dismiss = ''
    if [ -f ${lbnotif} ]; then
    notify-send "" "" --replace-id "$(cat ${lbnotif})" --expire-time 1 --transient; 
    else echo "no file to dismiss!";
    fi
  '';

  inherit (lib) mkIf types;
  inherit (eulib.options) mkOpt;
  cfg = config.eula.modules.home-manager.services.lowbatt;
in {
  options.eula.modules.home-manager.services.lowbatt.enable = mkOpt types.bool true;
  config.systemd.user = mkIf cfg.enable {
    timers.lowbatt = {
      Unit.Description = "check battery level";
      Timer = {
        OnBootSec = "5m";
        OnUnitInactiveSec = "5m";
        Unit = "lowbatt.service";
      };
      Install.WantedBy = ["timers.target"];
    };
    services.lowbatt = {
      Unit.Description = "battery level notifier";
      Service = {
        Type = "exec";
        PassEnvironment = "DISPLAY";
        ExecStart = "${pkgs.writeShellApplication {
          name = "lowbatt";
          runtimeInputs = [pkgs.libnotify pkgs.coreutils];
          text = ''
          battery_capacity=$(cat /sys/class/power_supply/${device}/capacity)
          ${dismiss}
          battery_status=$(cat /sys/class/power_supply/${device}/status)
          if [[ $battery_capacity -le ${builtins.toString critical} && $battery_status = "Discharging" ]]; then
              notify-send --urgency=critical --transient --print-id --icon=battery_empty "battery at $battery_capacity%" "DONT GET FUCKED!!1!" > ${lbnotif}
              sleep 60s
              battery_status=$(cat /sys/class/power_supply/${device}/status)
              battery_capacity=$(cat /sys/class/power_supply/${device}/capacity)
              if [[ $battery_status = "Discharging" && $battery_capacity -le ${builtins.toString critical} ]]; then
                  ${dismiss}
                  notify-send --print-id --urgency=critical --transient --icon=battery_empty "goodbye :3" "see you space cowboy..." > ${lbnotif}
                  systemctl hibernate
              fi
          elif [[ $battery_capacity -le ${builtins.toString notify} && $battery_status = "Discharging" ]]; then
              notify-send --print-id --urgency=critical --transient --icon=battery_empty "battery at $battery_capacity%" "go plug in your laptop, dumbass" > ${lbnotif}
          fi
          '';
        }}/bin/lowbatt";
        Restart = "on-failure";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
