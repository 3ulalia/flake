{
  config,
  inputs,
  lib,
  pkgs,
  niri,
  ...
} : 
  let 
    inherit (config.eula.lib.modules) any-user;
  in {

    imports = [ inputs.niri.nixosModules.niri ];

    nixpkgs.overlays = [inputs.niri.overlays.niri];
    
    programs.niri.enable = (any-user (user: user.eula.modules.home-manager.niri.enable) config.home-manager.users);
}
	      
