# Default configuration options relating to home-manager for each user.
# Imported by the user-wide `default.nix`. 
{
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  # imports = outputs.homeManagerModules;

  programs.home-manager.enable = mkDefault true;
  programs.git.enable = mkDefault true;

  nixpkgs.config.allowUnfree = mkDefault true;

  home = {
    stateVersion = mkDefault "21.05";
  };
}