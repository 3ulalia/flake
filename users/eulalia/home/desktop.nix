{ ... }:
{
  eula.modules.home-manager.desktop = {
    apps = {
      ctrl.enable = true;
      idle.enable = true;
      locker.enable = true;
      notif.enable = true;
      night-shift.enable = true;
      term.enable = true;
    };

    switches.lid-open = "niri msg action power-off-monitors";

  };
}
