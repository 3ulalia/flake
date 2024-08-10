{
  lib,
  nixpkgs,
  ...
} :
  let
    inherit (lib) types;
    inherit (lib.eula) mkOpt;
  in {
    users = mkOpt types.attrsOf (
      types.submodule {
        options = {
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
          shell = mkOpt types.package nixpkgs.zsh;
        };
      }
    );
  }