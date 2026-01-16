{
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    tinymist
    websocat
    typst
    typstyle
    # fonts
    libertinus
    newcomputermodern
    dejavu_fonts
  ];

}
