{config, ...}: {
  programs.wpaperd = {
    enable = true;
    settings = {
      default = {
        mode = "center";
        duration = "24h";
        path = ../../../artifacts/quiet-victories/backgrounds;
      };
    };
  };
}
