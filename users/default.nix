/*
*
This module defines the system-level settings that will be configured on every system using this flake.

Specifically, it dictates the sources for user configurations, nix settings, and time zone (some or all
of which can/will be overridden by home-manager).
*/
{
  config, # messy, but we need this so we know the list of users that have been specified for this system
  lib,
  eulib,
  pkgs,
  ...
}: let
  inherit (lib) any attrNames attrValues length filterAttrs mapAttrs mkIf trace;
  inherit (lib.attrsets) recursiveUpdate;

  config-users = config.eula.modules.nixos.users;
in {

  config = rec {
    users = {
      mutableUsers = false; # don't touch this! go add a folder to ../users like you're supposed to
      defaultUserShell = pkgs.zsh;

      # derived from config.users, which is defined in the module for the individual host
      users = eulib.users.generate-users config-users;
    };

    home-manager = {
      # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506
      #useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      users = eulib.users.generate-homes {} config-users;
    };

    programs.zsh.enable = any (user: user.shell == pkgs.zsh) (attrValues users.users);
  };
}
