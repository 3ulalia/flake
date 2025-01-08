{ 
  pkgs,
  ...
} : {

  programs.alacritty= {
    enable = true;
    settings = {
      font.normal.family = "Julia Mono";
      general.import = ["${pkgs.alacritty-theme.outPath}/solarized_osaka.toml"];
    };
  };

  home.packages = [pkgs.alacritty-theme];
}
