{
  inputs,
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    #inputs.lean4-nix.packages.${pkgs.stdenv.hostPlatform.system}.lean-all
    inputs.lean4-nix.packages.${pkgs.stdenv.hostPlatform.system}.lean
  ];

}
