{ config, pkgs, ... } : 

let
  locker = config.eula.modules.home-manager.desktop.locker;
  swcmd = "${locker.pkg}/bin/${locker.pkg.pname}";
  notif-id = "${config.xdg.stateHome}/idlenotif";
  niri = "${pkgs.niri}/bin/niri msg action";
  script = sc: "${sc}/bin/${sc.name}";

  notif = pkgs.writeShellApplication { 
    name = "idle-notify";
    runtimeInputs = [ pkgs.libnotify pkgs.coreutils ];
    text = ''
    notify-send -e -p -t 1000 'so sleepy' 'display will lock in 10 seconds...' > ${notif-id}
    for i in $(seq 10 -1 1); do
      notifid="$(cat ${notif-id})";
      notify-send -e -p -t 1000 -r "$notifid" "so sleepy" "display will lock in $i seconds..." > ${notif-id};
      sleep 1;
    done
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
    brightnessctl -q -s
    notify-send -e -p -t 5000 "so sleepy" "dimming screen; display will lock in 60 seconds" > ${notif-id}
    for _ in $(seq 1 10); do
      brightnessctl -q s 5%-;
      sleep 0.05;
    done
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
      { timeout = 60; command = "${script bright-fade}"; resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -q -r; ${script notif-dismiss}";}
      { timeout = 110; command = "${script notif}"; resumeCommand = "${script notif-dismiss}";}
      { timeout = 120; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
      { timeout = 300; command = "${niri} power-off-monitors"; resumeCommand = "${niri} power-on-monitors";}
      { timeout = 900; command = "systemctl suspend"; }
    ];
  };
}
