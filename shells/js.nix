{
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    nodejs_24
    prettier
    eslint
    eslint_d
    nodePackages.typescript-language-server
  ];

}
