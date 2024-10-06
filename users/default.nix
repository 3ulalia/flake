/**
  This module defines the system-level settings that will be configured on every system using this flake.

  Specifically, it dictates the sources for user configurations, nix settings, and time zone (some or all
  of which can/will be overridden by home-manager).
 */

{
  bootstrap,
  config, # messy, but we need this so we know the list of users that have been specified for this system
  inputs,
  outputs,
  lib,
  pkgs,
  ...
} : 
  let

  inherit (lib) attrNames length filterAttrs mapAttrs mkIf trace;
  inherit (lib.attrsets) recursiveUpdate;

  ans-settings = {
    programs.zsh.enable = true;
    programs.zsh.initExtra = "any-nix-shell zsh --info-right | source /dev/stdin";
    home = {packages = [pkgs.any-nix-shell];};
  };

  users = config.eula.modules.nixos.users;
  in {

    #imports = map (n: ./. + ("/" + n)) (bootstrap.modules.nix-modules-in-dir [__curPos.file (builtins.toString ./home.nix)] ./.); 

    config = {

      users = {
        
        mutableUsers = false; # don't touch this! go add a folder to ../users like you're supposed to
        defaultUserShell = pkgs.zsh;

        # derived from config.users, which is defined in the module for the individual host
        users = config.eula.lib.users.generate-users users;
      };

      home-manager = {

        useGlobalPkgs = true;
        useUserPackages = true;
	backupFileExtension = "backup";
	
	users = mapAttrs 
	  (n: u: recursiveUpdate u (if users.${n}.shell == pkgs.zsh then ans-settings else {}))
	  (config.eula.lib.users.generate-homes {} users);
      };

    programs.zsh.enable = true;

    }; 
  }

