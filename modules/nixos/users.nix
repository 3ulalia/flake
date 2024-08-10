{
  lib,
  nixpkgs,
  options,
  ...
} :
  let
    inherit (lib) types;
    inherit (lib.eula) mkOpt;
  in {
    options.users = mkOpt types.listOf (
      types.submodule {
        options = {
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
          shell = mkOpt types.package nixpkgs.zsh;
        };
      }
    );
  }
