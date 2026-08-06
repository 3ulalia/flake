{
  buildPackages,
  kernel,
  lib,
  pkgs,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "apple-bce";
  version = "7cad7c";

  src = pkgs.fetchFromGitHub {
    owner = "deqrocks";
    repo = "apple-bce";
    rev = "7cad7c8fb2a03825377de3d9a7beceaa73b197b5";
    hash = "";
  };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)/lib/modules/${kernel.modDirVersion}/kernel"
    # from pkgs/os-specific/linux/kernel/manual-config.nix:
    "O=$(buildRoot)"
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
    "HOSTLD=${buildPackages.stdenv.cc.bintools}/bin/${buildPackages.stdenv.cc.targetPrefix}ld"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  # NixOS kernel expects compressed kernel modules, so do that here.
  postInstall = ''
    find $out -name '*.ko' -exec xz {} \;
  '';
}
