{
  config,
  lib,
  ...
} : 
  let
    inherit (lib) mkEnableOption mkIf;
  in {
  options.eula.modules.home-manager.stylix.enable = mkEnableOption "stylix";

  config.stylix = mkIf config.eula.modules.home-manager.stylix.enable {
    enable = true;
    image = config.eula.modules.home-manager.wpaperd.path;
  };
}
