{ config, pkgs, ... } : 

let
  locker = config.eula.modules.home-manager.niri.locker;
  swcmd = "${locker.pkg}/bin/${locker.pkg.pname}";
  notif-id = "${config.xdg.stateHome}/idlenotif";
  niri = "${pkgs.niri}/bin/niri msg action";
  script = sc: "${sc}/bin/${sc.name}";

  notif = pkgs.writeShellApplication { 
    name = "idle-notify";
    runtimeInputs = [ pkgs.libnotify ];
    text = "notify-send -p -t 10000 'so sleepy' 'display will sleep in 10 seconds...' > ${notif-id}";
  };
  notif-dismiss = pkgs.writeShellApplication {
    name = "idle-dismiss";
    runtimeInputs = [ pkgs.mako pkgs.coreutils ];
    text = "makoctl dismiss -n \"$(cat ${notif-id})\"";
  };
  bright-fade = pkgs.writeShellApplication {
    name = "bright-fade";
    runtimeInputs = [ pkgs.brightnessctl pkgs.coreutils ];
    text = ''
    brightnessctl -q -s
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
      { timeout = 60; command = "${script bright-fade}"; resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -q -r";}
      { timeout = 80; command = "${script notif}"; resumeCommand = "${script notif-dismiss}";}
      { timeout = 90; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
      { timeout = 180; command = "${niri} power-off-monitors"; resumeCommand = "${niri} power-on-monitors";}
      { timeout = 900; command = "systemctl suspend"; }
    ];
  };
}
