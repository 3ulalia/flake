{config, ...}: {
  programs.wpaperd = {
    enable = true;
    settings = {
      default = {
        mode = "stretch";
        duration = "24h";
        path = ../../../artifacts/quiet-victories;
      };
    };
  };
}
