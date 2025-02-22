{config, pkgs, ...}: {
  eula.modules.home-manager.desktop.bg = {
    pkg = pkgs.wpaperd;
    enable = true;
    type = "services";
  };
  services.wpaperd = {
    settings = {
      default = {
        mode = "center";
        duration = "24h";
        path = ../../../artifacts/quiet-victories/backgrounds;
      };
    };
  };
}
