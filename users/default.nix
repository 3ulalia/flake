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
} : 
  let

  inherit (lib.eula) generateUsers patch-extra-groups;

  in {
    config = {

      users = {
        
        mutableUsers = false; # don't touch this! go add a folder to ../users like you're supposed to
        defaultUserShell = pkgs.zsh;

        # derived from config.modules.users, which is defined in the module for the individual host
        users = patch-extra-groups config.users.extraGroups (generateUsers config.modules.users);
      };
    };
  }
    