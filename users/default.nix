/**
  This module defines the system-level settings that will be configured on every system using this flake.

  Specifically, it dictates the sources for user configurations, nix settings, and time zone (some or all
  of which can/will be overridden by home-manager).
 */

{
  config, # messy, but we need this so we know the list of users that have been specified for this system
  inputs,
  outputs,
  lib,
  pkgs,
  ...
} : 
  let

  inherit (lib) attrNames length filter mkIf trace elemAt;

  # config (as loaded from hosts/<hostname>/default.nix) will hold a custom option `users`
  # this is defined in modules/nixos/users.nix, which is loaded as into flake.nix::nixosModules.
  # it is a list of attrsets containing basic user configurations.
  cfg = trace config.eula.modules.nixos.users config.eula.modules.nixos.users;

  is-empty = l: (length l) == 0;
  
  extra-settings = {programs.zsh.enable = (!(is-empty (filter (v: v.shell == pkgs.zsh) config.eula.modules.nixos.users)));};

  users = config.eula.lib.users.generate-homes extra-settings cfg; 
  in {

    config = {

      users = {
        
        mutableUsers = false; # don't touch this! go add a folder to ../users like you're supposed to
        defaultUserShell = pkgs.zsh;

        # derived from config.users, which is defined in the module for the individual host
        users = config.eula.lib.users.generate-users cfg;
      };

      home-manager = {

        useGlobalPkgs = true;
        useUserPackages = true;
	
	users = trace users.eulalia.programs.zsh.enable users;
        
      };
    } // extra-settings;
  }

