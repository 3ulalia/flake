{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [
    pkgs.pavucontrol
    pkgs.vesktop
    pkgs.signal-desktop
    #pkgs.nautilus
  ];
  eula.modules.home-manager.desktop = {
    spawn-at-startup = ["signal-desktop --use-tray-icon --ozone-platform-hint=auto"];
  };
}
