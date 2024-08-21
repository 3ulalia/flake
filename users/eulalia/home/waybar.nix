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
     }; };
    };
}
