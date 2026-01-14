{
  config,
  lib,
  pkgs,
  ...
}: 

let
  conf = config.eula.modules.home-manager.desktop.apps.bar;
  configure-huh = (conf.pkg == pkgs.waybar) && conf.opinionated && conf.enable;
in {
  
  eula.modules.home-manager.desktop.apps.bar.type = lib.mkIf configure-huh "programs";
  eula.modules.home-manager.desktop.spawn-at-startup = lib.mkIf configure-huh ["nm-applet"];
  programs.waybar = lib.mkIf configure-huh {
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-center = ["clock" "battery"];

        modules-left = ["niri/workspaces" "wlr/taskbar"];

        modules-right = ["tray"];

        "battery" = {
          "tooltip-format" = "{time}";
        };
        "clock" = {
          "tooltip-format" = "{:L%c}";
        };
      };
    };
  };
  home.packages = [
    pkgs.networkmanagerapplet
  ];
  
}
