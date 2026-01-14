{
  config,
  lib,
  pkgs, 
  ...
}: 
let

  conf = config.eula.modules.home-manager.desktop.apps.term;
  configure-huh = (conf.pkg == pkgs.alacritty) && conf.opinionated && conf.enable;

in {
  programs.alacritty = {
    settings = {
      font.normal.family = "PlemolJP Console NF";
      font.size = 12.5;
      general.import = ["${pkgs.alacritty-theme.outPath}/share/alacritty-theme/solarized_osaka.toml"];
    };
  };

  home.packages = [pkgs.alacritty pkgs.alacritty-theme];
}
