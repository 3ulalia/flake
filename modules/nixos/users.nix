{
  lib,
  ...
} :
  let
    inherit (lib) types;
    inherit (lib.eula) mkOpt;
  in {

    users = mkOpt types.listOf (
      types.submodule {
        options = {
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
        };
      }
    );

  }