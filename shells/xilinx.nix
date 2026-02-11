{
  inputs,
  pkgs,
  ...
}:
let
  inherit (pkgs) lib;
in
{

  NIX_LD_LIBRARY_PATH =
    with pkgs;
    lib.makeLibraryPath [
      bash
      util-linux
      coreutils
      zlib
      lsb-release
      stdenv.cc.cc
      ncurses
      ncurses5
      xorg.libXext
      xorg.libX11
      xorg.libXrender
      xorg.libXtst
      xorg.libXi
      xorg.libXft
      xorg.libxcb
      # common requirements
      freetype
      fontconfig
      glib
      gtk2
      gtk3
      libxcrypt-legacy
      libdrm
      libgbm
      pixman
      libpng
      # For fetching project templates when creating projects
      gitMinimal
      # For the `arch` command
      toybox


      # to compile some xilinx examples
      opencl-clhpp
      ocl-icd
      opencl-headers

      # from installLibs.sh
      graphviz
      gcc
      unzip
      nettools
    ];
  NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  _JAVA_AWT_WM_NONREPARENTING = 1;

  shellHook = inputs.nix-xilinx.shellHooksCommon;

}
