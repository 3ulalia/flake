{ config, pkgs, ... } : 

let 
  locker = config.eula.modules.home-manager.desktop.locker;
  swcmd = "${locker.pkg}/bin/${locker.pkg.pname}";
  notif-id = "${config.xdg.stateHome}/idlenotif";
  niri = "/run/current-system/bin/sw/niri msg action";
  script = sc: "${sc}/bin/${sc.name}";
  brightness-exponent = "2.5";
  brightness-cmd = "brightnessctl -q -m --exponent=${brightness-exponent}";

  notif = pkgs.writeShellApplication { 
    name = "idle-notify";
    runtimeInputs = [ pkgs.libnotify pkgs.coreutils ];
    text = ''
    notify-send -e -p -t 11000 'so sleepy' 'display will lock in 10 seconds...' > ${notif-id}
    '';
  };
  notif-dismiss = pkgs.writeShellApplication {
    name = "idle-dismiss";
    runtimeInputs = [ pkgs.mako pkgs.coreutils ];
    text = "makoctl dismiss -n \"$(cat ${notif-id})\"";
  };
  bright-fade = pkgs.writeShellApplication {
    name = "bright-fade";
    runtimeInputs = [ pkgs.brightnessctl pkgs.coreutils pkgs.libnotify ];
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
in {

  home.packages = [pkgs.libnotify];

  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = swcmd; }
      { event = "lock"; command = swcmd; }
    ];
    extraArgs = [ "-w" ];
    timeouts = [
      { timeout = 60; command = "${script bright-fade}"; resumeCommand = "${script notif-dismiss}; ${pkgs.brightnessctl}/bin/brightnessctl --restore";}
      { timeout = 110; command = "${script notif}"; resumeCommand = "${script notif-dismiss}"; }
      { timeout = 120; command = "${pkgs.systemd}/bin/loginctl lock-session"; }#resumeCommand = "${pkgs.systemd}/bin/loginctl unlock-session";}
      { timeout = 300; command = "${niri} power-off-monitors"; resumeCommand = "${niri} power-on-monitors"; }
      { timeout = 900; command = "systemctl hibernate"; }
    ];
  };
}
