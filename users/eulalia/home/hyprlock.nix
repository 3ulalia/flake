{ config, osConfig,  pkgs, ... } : 
let
  text-color = "rgba(237,231,228,0.9)";
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
        immediate_render = true;
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
          color = text-color;
          font_family = "DejaVu Sans";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
        {
          text = "$TIME";
          color = text-color;
          font-family = "DejaVu Sans";
          font_size = 48;
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];
      
    };
  };
}
