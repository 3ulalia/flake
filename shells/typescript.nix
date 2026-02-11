{
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    nodejs_24
    prettier
    prettierd
    eslint
    eslint_d
    vtsls
  ];

}
