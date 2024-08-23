# Default configuration options relating to home-manager for each user.
# Imported by the user-wide `default.nix`. 
{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) attrNames length filterAttrs mkDefault mkIf trace; # TODO write library function to determine if a user has a setting enabled
in {
  #imports = [../modules/home-manager];

  # This may seem cavalier. However, since anyone using this flake is also locked
  # into using home-manager, we _should_ always have git in our environment.
  # should.
  programs.git.enable = true;
  programs.home-manager.enable = (trace "evaluating users/home.nix!" true);
}

