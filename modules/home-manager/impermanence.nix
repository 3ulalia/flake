{
  config,
  eulib,
  lib,
  ...
}: let
  inherit (eulib.options) mkOpt;
  inherit (lib) mkIf types;

  cfg = config.eula.modules.home-manager.impermanence;
in {
  options.eula.modules.home-manager.impermanence = {
    enable = mkOpt types.bool false;
    directories = mkOpt (types.listOf types.str) [];
    files = mkOpt (types.listOf types.str) [];
  };

  config = mkIf cfg.enable {
    home.persistence."/persist" = {
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
    };
  };
}
