# Default configuration options relating to home-manager for each user.
# Imported by the user-wide `default.nix`. 
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) attrNames length filterAttrs mkDefault mkIf trace; # TODO write library function to determine if a user has a setting enabled
in {
  imports = [../modules/home-manager];

  programs.home-manager.enable = mkDefault true;
  programs.git.enable = mkDefault true;
  nixpkgs.config.allowUnfree = mkDefault true;
}

