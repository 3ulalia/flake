{
  config,
  lib,
  pkgs,
 ...
} : 
  let   
    inherit (lib) trace mkIf;
    inherit (config.eula.lib.modules) any-user;
  in {
      config = mkIf (any-user (user: user.programs.waybar.enable) config.home-manager.users) {
        fonts.packages = [
          pkgs.meslo-lg
          (pkgs.nerdfonts.override { fonts = ["Meslo"]; })
        ];
      };
    }


  
