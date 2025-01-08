{
  config,
  lib,
  osConfig,
  ...
}: let
  inherit (osConfig.eula.lib.options) mkOpt;
  inherit (lib) mkIf types;
in {
  options.eula.modules.home-manager.starship = {
    enable = mkOpt types.bool false;
  };

  config = mkIf config.eula.modules.home-manager.starship.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      # TODO add configuration options to the home-manager module
    };
  };
}
