{
  config,
  lib,
  pkgs,
  ...
}: let
  text-color = a: "rgba(237,231,228,${builtins.toString a})";
  text-font = "Mona Sans";
  # TODO: make this a module
  scaling-factor = 1.5;
  scale = n: builtins.floor (n * scaling-factor);
  scales = n: builtins.toString (scale n);

  conf = config.eula.modules.home-manager.desktop.apps.locker;
  configure-huh = (conf.pkg == pkgs.hyprlock) && conf.opinionated && conf.enable;

in {
  eula.modules.home-manager.desktop.apps.locker.type = lib.mkIf configure-huh "programs";
  programs.hyprlock = lib.mkIf configure-huh {
    # _sigh_ my idealism
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        immediate_render = false;
      };
      background = [
        {
          path = "${config.xdg.stateHome}/wpaperd/wallpapers/eDP-1";
          blur_passes = 2;
          blur_size = 1;
          brightness = 0.5;
          vibrancy = 0.2;
          vibrancy_darkness = 0.2;
        }
      ];
      label = [
        {
          text = "login as: ${config.home.username}";
          color = text-color 0.9;
          font_family = text-font + " SemiBold";
          font_size = scale 14;
          position = "0, ${scales 100}";
          halign = "center";
          valign = "bottom";
        }
        {
          text = "$TIME";
          color = text-color 0.9;
          font_family = text-font + " Bold";
          font_size = scale 96;
          position = "0, ${scales (-100)}";
          halign = "center";
          valign = "top";
        }
        {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +"%A, %b %d"'';
          color = text-color 0.9;
          font_family = text-font + " Bold";
          font_size = scale 20;
          position = "0, ${scales (-75)}";
          halign = "center";
          valign = "top";
        }
        {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/echo "battery $(( 100 * $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/charge_now) / $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/charge_full) ))% charged"'';
          color = text-color 0.9;
          font_family = text-font + " Semibold";
          font_size = scale 14;
          position = "0, ${scales (-250)}";
          halign = "center";
          valign = "top";
        }
      ];
      input-field = [
        {
          size = "${builtins.toString (200 * scaling-factor)},${builtins.toString (25 * scaling-factor)}";
          dots_size = 0.5;
          placeholder_text = "";
          inner_color = text-color 0.9;
          #font_color = "rgba(17,17,17,0.6)";
          outline_thickness = 0;
          position = "0,${scales 50}";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
