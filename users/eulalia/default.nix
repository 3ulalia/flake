{
  config,
  pkgs,
  ...
} : 

  { 

    config.eula = {
      modules.niri.enable = true;
    };

  }
