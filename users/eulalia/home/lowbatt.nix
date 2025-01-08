{ config, lib, pkgs, ... }:

with lib;
let
  notify = 10;
  critical = 5;
in
{
  config = mkIf cfg.enable {
    systemd.user.timers."lowbatt" = {
      description = "check battery level";
      timerConfig.OnBootSec = "5m";
      timerConfig.OnUnitInactiveSec = "5m";
      timerConfig.Unit = "lowbatt.service";
      wantedBy = [ "timers.target" ];
    };
    systemd.user.services."lowbatt" = {
      description = "battery level notifier";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        export battery_capacity=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/capacity)
        export battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/status)
        if [[ $battery_capacity -le ${builtins.toString notify} && $battery_status = "Discharging" ]]; then
            ${pkgs.libnotify}/bin/notify-send --urgency=critical --hint=int:transient:1 --icon=battery_empty "battery at $battery_capacity%"
        fi
        if [[ $battery_capacity -le ${builtins.toString critical} && $battery_status = "Discharging" ]]; then
            ${pkgs.libnotify}/bin/notify-send --urgency=critical --hint=int:transient:1 --icon=battery_empty "battery at $battery_capacity% DONT GET FUCKED!!1!"
            sleep 60s
            battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${cfg.device}/status)
            if [[ $battery_status = "Discharging" ]]; then
                ${pkgs.libnotify}/bin/notify-send --urgency=critical --hint=int:transient:1 --icon=battery_empty "goodbye :3"
                systemctl suspend
            fi
        fi
      '';
    };
  };
}
