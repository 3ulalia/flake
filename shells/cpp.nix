{
  pkgs,
  ...
}:
{

  packages = with pkgs; [
    boost
    ccls
    gdb
    #    cmake
  ];

}
