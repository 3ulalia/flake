# Default home-manager config for each user's home
{
  lib,
  outputs,
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