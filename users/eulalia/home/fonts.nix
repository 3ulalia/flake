{
  config,
  pkgs,
  ...
}: {
  fonts.fontconfig = {
    enable = true;
  };
  home.packages = [
    pkgs.plemoljp-nf
    pkgs.mona-sans
  ];
}
