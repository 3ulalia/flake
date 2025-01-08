{ config, ... } : 

let
  swcmd = config.eula.modules.home-manager.niri.locker.cmd;
in {
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = swcmd; }
    ];
    extraArgs = [ "-w" ];
    timeouts = [
      { timeout = 5; command = swcmd; }
      { timeout = 10; command = "niri msg action power-off-monitors"; resumeCommand = "niri msg action power-on-monitors";}
    ];
  };
}
