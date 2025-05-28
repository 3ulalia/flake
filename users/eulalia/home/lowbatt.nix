{
  config,
  pkgs,
  ...
}: let
  notify = 10;
  critical = 5;
  device = "BAT0";
  lbnotif = "${config.xdg.stateHome}/lbnotif";
  dismiss = "${pkgs.mako}/bin/makoctl dismiss -n $(${pkgs.coreutils}/bin/cat ${lbnotif})";
in {
  systemd.user.timers.lowbatt = {
    Unit.Description = "check battery level";
    Timer = {
      OnBootSec = "5m";
      OnUnitInactiveSec = "5m";
      Unit = "lowbatt.service";
    };
    Install.WantedBy = ["timers.target"];
  };
  systemd.user.services.lowbatt = {
    Unit.Description = "battery level notifier";
    Service = {
      Type = "exec";
      PassEnvironment = "DISPLAY";
      ExecStart = pkgs.writeShellScript "lowbatt" ''
        export battery_capacity=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${device}/capacity)
        ${dismiss}
        export battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${device}/status)
        if [[ $battery_capacity -le ${builtins.toString critical} && $battery_status = "Discharging" ]]; then
            ${pkgs.libnotify}/bin/notify-send --urgency=critical --transient --print-id --icon=battery_empty "battery at $battery_capacity%" "DONT GET FUCKED!!1!" > ${lbnotif}
            sleep 60s
            battery_status=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/${device}/status)
            if [[ $battery_status = "Discharging" && $battery_capacity -le ${builtins.toString critical} ]]; then
                ${dismiss}
                ${pkgs.libnotify}/bin/notify-send --print-id --urgency=critical --hint=int:transient:1 --icon=battery_empty "goodbye :3" "see you space cowboy..." > ${lbnotif}
                systemctl hibernate
            fi
        elif [[ $battery_capacity -le ${builtins.toString notify} && $battery_status = "Discharging" ]]; then
            ${pkgs.libnotify}/bin/notify-send --print-id --urgency=critical --hint=int:transient:1 --icon=battery_empty "battery at $battery_capacity%" "go plug in your laptop, dumbass" > ${lbnotif}
        fi
      '';
      Restart = "on-failure";
    };
    Install.WantedBy = ["default.target"];
  };
}
