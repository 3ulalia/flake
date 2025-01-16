{ config,  pkgs, ... } : 
let
  text-color = a: "rgba(237,231,228,${builtins.toString a})";
  text-font = "Mona Sans";
in {
  eula.modules.home-manager.desktop.locker= {
    pkg = pkgs.hyprlock;
    enable = true;
    type = "programs";
  };
  programs.hyprlock = { # _sigh_ my idealism
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
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
          font_size = 14;
          position = "0, 100";
          halign = "center";
          valign = "bottom";
        }
        {
          text = "$TIME";
          color = text-color 0.9;
          font_family = text-font + " Bold";
          font_size = 96;
          position = "0, -100";
          halign = "center";
          valign = "top";
        }
        {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +"%A, %b %d"'';
          color = text-color 0.9;
          font_family = text-font + " Bold";
          font_size = 20;
          position = "0, -75";
          halign = "center";
          valign = "top";
        }
        {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/echo "battery $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/capacity)% charged"'';
          color = text-color 0.9;
          font_family = text-font + " Semibold";
          font_size = 14;
          position = "0, -250";
          halign = "center";
          valign = "top";
        }
      ];
      input-field = [
        {
          size = "200,25";
          dots_size = 0.5;
          placeholder_text = "";
          inner_color = text-color 0.9;
          #font_color = "rgba(17,17,17,0.6)";
          outline_thickness = 0;
          position = "0,50";
          halign = "center";
          valign = "bottom";
        }
      ];
    };
  };
}
