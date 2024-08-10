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

  inherit (lib) attrNames trace elemAt;
  inherit (lib.eula) generate-homes generate-users;


  # config (as loaded from hosts/<hostname>/default.nix) will hold a custom option `users`
  # this is defined in modules/nixos/users.nix, which is loaded as into flake.nix::nixosModules.
  # it is an attrset mapping user name to user configuration.
  cfg = config.users;

  in {

    config = {

      users = {
        
        mutableUsers = false; # don't touch this! go add a folder to ../users like you're supposed to
        defaultUserShell = pkgs.zsh;

        # derived from config.users, which is defined in the module for the individual host
        users = generate-users cfg;
      };

      home-manager = {

        useGlobalPkgs = true;
        useUserPackages = true;

        users = generate-homes cfg; 
      };
    };
  }
    
