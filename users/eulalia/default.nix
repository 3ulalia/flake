{
  config,
  pkgs,
  ...
} : 
  { 
    config.eula.modules = {

      services = {
	ly.enable = true;
      };

      nixos = {
        niri.enableFor = ["eulalia"];
	audio.enable = true;
        bluetooth.enable = true;


 	users.eulalia.home-config.eula.modules = {
 	  home-manager.firefox.enable = true;
 	  home-manager.alacritty.enable = true;
 	  home-manager.signal-desktop.enable = true;
        };
      };
    };
  }
