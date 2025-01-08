{
  config,
  inputs,
  lib,
  ...
} : 
let
  inherit (lib) mkIf;
  inherit (config.eula.lib.modules) any-user;
in {

  imports = [inputs.stylix.nixosModules.stylix];

  config = mkIf (any-user (user: user.stylix.enable) config.home-manager.users) {
    
  };
}
