{
  lib,
  pkgs,
  inputs,
  config,
  osConfig,
  ...
} : {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    extraPlugins = [
          (pkgs.vimUtils.buildVimPlugin {
            pname = "solarized-osaka";
            version = "2025-01-02";
            src = pkgs.fetchFromGitHub {
              owner = "craftzdog";
              repo = "solarized-osaka.nvim";
              rev = "44d3b9d966a632ff42746cf326c5fa4e2b30bb92";
              sha256 = "sha256-kh/+DddCiUBP4EVZ5SgmkPH+qHj/NdwwLPgwY1oKeXA=";
            };
            meta.homepage = "https://github.com/craftzdog/solarized-osaka.nvim";
          })
          pkgs.vimPlugins.LazyVim
        ];

    colorscheme = "solarized-osaka";
  };
}
