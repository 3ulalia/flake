{
  bootstrap,
  config,
  lib,
  pkgs,
  ...
} : {

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = { mainBar = {
	layer = "top";
	position = "top";	
	height = 30;

	modules-center = ["clock" "battery" "network"];

	"battery" = {
	  "tooltip-format" = "{time}";
	};
	"clock" = {
	  "tooltip-format" = "{:%c}";  
	};
	"network" = {
	  "format-wifi" = "{icon}";
	  "format-icons" = ["󰤟" "󰤢" "󰤥" "󰤨"];
	  "tooltip-format-wifi" = "{essid} ({signalStrength}%)";
	};
     }; };

    /*
    style = ''
      window#waybar { 
	background = transparent;
      }
    '';
    */
    };
}
