{
  config,
  pkgs,
  ...
} : 

  { 

    config.eula = {
      modules.home-manager.niri.enable = true;
      modules.home-manager.ly.enable = false;
      modules.home-manager.alacritty.enable = true;
      modules.home-manager.signal-desktop.enable = true;
    };

  }
