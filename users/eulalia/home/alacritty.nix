{ 
  pkgs,
  ...
} : {

  programs.alacritty = {
    settings = {
      font.normal.family = "PlemolJP Console NF";
      font.size = 12.5;
      general.import = ["${pkgs.alacritty-theme.outPath}/solarized_osaka.toml"];
    };
  };

  home.packages = [pkgs.alacritty-theme];
}
