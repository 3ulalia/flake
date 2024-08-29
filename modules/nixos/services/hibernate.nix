{
  config,
  inputs,
  lib,
  pkgs,
  ...
} : 
  let 
    inherit (builtins) length;
    inherit (lib) mkOption mkIf mkAliasDefinitions trace types;
    inherit (config.eula.lib.helpers) list-to-attrs;
    inherit (config.eula.lib.options) mkOpt;
  in {

    options.eula.modules.services.hibernate = {
      enable = mkOpt types.bool false;
      resume-offset = (mkOpt types.int 0) // { description = ''
	The offset into the swapfile to resume from.
	Determined from this link according to your FS type:
	https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset''; };
      resume-device = mkOpt types.str "/dev/disk/by-label/nixos";
    };
    
    config = mkIf config.eula.modules.services.hibernate.enable {
      boot = {
	kernelParams = ["resume_offset=${toString config.eula.modules.services.hibernate.resume-offset}"];
	resumeDevice = config.eula.modules.services.hibernate.resume-device;
      };
    };
  }
	      
