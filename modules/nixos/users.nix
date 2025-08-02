{
  config,
  eulib,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  mkOpt = eulib.options.mkOpt;
in {
  options.eula.modules.nixos.users = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = rec {
          extraGroups = mkOpt (types.listOf types.str) [];
          name = mkOpt types.str "user";
          privileged = mkOpt types.bool false;
          shell = mkOpt types.package pkgs.zsh;
          home-config = mkOpt (types.attrsOf types.anything) {};
          sops = mkOpt (types.submodule {
              options = {
                enable = mkOpt types.bool false;
                builtins-hack = mkOpt types.bool false; # TODO
                i-understand-the-security-implications = mkOpt types.bool false; # TODO
                key-type = mkOpt (types.enum ["gnupg" "age" "ssh"]) "ssh"; # TODO
                key-path = mkOpt (types.nullOr types.str) null; 
              };
          }) {}; 
        };
      }
    );
  };
}
