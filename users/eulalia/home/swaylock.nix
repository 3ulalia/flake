{config, ...}: {
  config.eula.modules.home-manager.swaylock = {
    enable = true;
    background.image.path = "${config.xdg.stateHome}/wpaperd/wallpapers/eDP-1";
    indicator = {
      content = {
        text = {
          font = "Julia Mono";
          color = {
            color =     "FFFFFFFF";
            clear =     "FFFFFFFF";
            caps-lock = "FFFFFFFF";
            ver =       "FFFFFFFF";
            wrong =     "FFFFFFFF";
          };
        };
        color = {
          color = "073541DD";
          clear = "B38600FF";
          caps-lock = "D33682DD";
          ver = "859900DD";
          wrong = "DC312EFF";
        };
      };
      colors = rec {
        ring = {
          color = "002D38DD";
          clear = "664D00FF";
          caps-lock = "B02769DD";
          ver = "586600DD";
          wrong = "B7221FFF";
        };
        segments = {
          keypress = "6D72C5FF";
          caps-lock = "D33682FF";
        };
        backspace = {
          keypress = "494EB6EE";
          caps-lock = "B02769EE";
        };
        separator = ring.color;
      };
    };
  };
}
