{
  config,
  pkgs,
  ...
} : 

  { 

    config = {
      modules.niri.enable = true;
    };



  }
