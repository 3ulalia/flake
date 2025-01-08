{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
}: {
  programs.waybar = {
    enable = true;
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
}
