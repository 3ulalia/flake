{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
}: {
  eula.modules.home-manager.desktop.bar = {
    pkg = pkgs.waybar;
    enable = true;
    type = "programs";
  };
  programs.waybar = {
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
          "tooltip-format" = "{:%c}";
        };
      };
    };
  };
  home.packages = [
    pkgs.networkmanagerapplet
  ];
}
