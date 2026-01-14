{
  config,
  pkgs,
  lib,
  ...
}: let
  locker = config.eula.modules.home-manager.desktop.apps.locker;
  swcmd = "${locker.pkg}/bin/${locker.pkg.pname}";
  notif-id = "${config.xdg.stateHome}/idlenotif";
  niri = "${config.programs.niri.package}/bin/niri msg action";
  script = sc: "${sc}/bin/${sc.name}";
  brightness-exponent = "2.5";
  brightness-cmd = "brightnessctl -q -m --exponent=${brightness-exponent}";

  notif = pkgs.writeShellApplication {
    name = "idle-notify";
    runtimeInputs = [pkgs.libnotify pkgs.coreutils];
    text = ''
      notify-send -e -p -t 11000 'so sleepy' 'display will lock in 10 seconds...' > ${notif-id}
    '';
  };
  notif-dismiss = pkgs.writeShellApplication {
    name = "idle-dismiss";
    runtimeInputs = [pkgs.mako pkgs.coreutils];
    text = "makoctl dismiss -n \"$(cat ${notif-id})\"";
  };
  bright-fade = pkgs.writeShellApplication {
    name = "bright-fade";
    runtimeInputs = [pkgs.brightnessctl pkgs.coreutils pkgs.libnotify];
    text = ''
      ${brightness-cmd} --save
      cb=$(${brightness-cmd} | cut -d, -f4 | cut -d% -f1)
      if [[ $cb -gt 10 ]]; then
        notify-send -e -p -t 5000 "so sleepy" "dimming screen; display will lock in 60 seconds" > ${notif-id}
        step=$(( (cb - 10) / 10 ))
        for _ in $(seq 1 10); do
          ${brightness-cmd} set $step%-;
          #sleep 0.01;
        done
        ${brightness-cmd} set 10%
      else
        notify-send -e -p -t 5000 "so sleepy" "already dimmed! display will lock in 60 seconds" > ${notif-id}
      fi
    '';
  };
  conf = config.eula.modules.home-manager.desktop.apps.idle;
  configure-huh = (conf.pkg == pkgs.hypridle) && conf.opinionated && conf.enable;
in {
  
  config.home.packages = lib.mkIf configure-huh [pkgs.libnotify];

  config.services.hypridle = lib.mkIf configure-huh {
    enable = true;
    settings = {
      general = {
        lock_cmd = swcmd;
        # unlock_cmd = send SIGUSR2 to hyprlock somehow
        before_sleep_cmd = "loginctl lock-session";
        inhibit_sleep = 3;
      };

      listener = [
        {
          timeout = 60;
          on-timeout = "${script bright-fade}";
          on-resume = "${script notif-dismiss}; ${pkgs.brightnessctl}/bin/brightnessctl --restore";
        }
        {
          timeout = 110;
          on-timeout = "${script notif}";
          on-resume = "${script notif-dismiss}";
        }
        {
          timeout = 120;
          on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = 300;
          on-timeout = "${niri} power-off-monitors";
          on-resume = "${niri} power-on-monitors";
        }
        {
          timeout = 900;
          on-timeout = "${pkgs.systemd}/bin/systemctl hibernate";
        }
      ];
    };
  };
}
