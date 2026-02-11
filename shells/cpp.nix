{
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    boost
#    cmake
  ] ;

}
