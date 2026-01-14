{
  config,
  eulib,
  inputs,
  lib,
  ...
}: let
  inherit (eulib.options) mkOpt;
  inherit (lib) mkIf types;

  cfg = config.eula.modules.home-manager.impermanence;
in {
#  imports = [inputs.impermanence.homeManagerModules.impermanence]; # no longer needed!

  options.eula.modules.home-manager.impermanence = {
    enable = mkOpt types.bool false;
    directories = mkOpt (types.listOf types.str) [];
    files = mkOpt (types.listOf types.str) [];
    allowOther = mkOpt types.bool true;
  };

  config = mkIf cfg.enable {
  /* here goes nothing...
    home.persistence."/persist${config.home.homeDirectory}" = {
      enable = true;
      directories =
        [
          "Documents"
          "Downloads"
          "Pictures"
          ".ssh"
          ".cache"
        ]
        ++ cfg.directories;
      files =
        [
        ]
        ++ cfg.files;
#      allowOther = cfg.allowOther; # no longer needed!
    };
*/
  };
}
