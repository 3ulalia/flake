# Default configuration options relating to home-manager for each user.
# Imported by the user-wide `default.nix`.
{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) any attrValues length filterAttrs mkDefault mkIf trace;

  zsh-enable = any (user: user.shell == pkgs.zsh) (attrValues osConfig.users.users);
in {
  #imports = [../modules/home-manager];

  # This may seem cavalier. However, since anyone using this flake is also locked
  # into using home-manager, we _should_ always have git in our environment.
  # should.
  programs.git.enable = true;
  programs.home-manager.enable = trace "evaluating users/home.nix!" true;

  programs.zsh = mkIf zsh-enable {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
