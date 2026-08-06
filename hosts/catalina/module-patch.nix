{
  kernelPackages,
  module,
  patches,
}:
kernelPackages.stdenv.mkDerivation {
  pname = builtins.baseNameOf module;
  inherit (kernelPackages.kernel) version src;

  inherit patches;

  nativeBuildInputs = kernelPackages.kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  makeFlags = kernelPackages.kernelModuleMakeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
    "INSTALL_MOD_DIR=kernel/${builtins.dirOf module}"
    "M=$(PWD)/${builtins.dirOf module}"
  ];

  buildFlags = [ "modules" ];

  installFlags = [ "modules_install" ];
}
