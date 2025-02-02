{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) length;
  inherit (lib) mkDefault mkIf mkAliasDefinitions trace types;
  inherit (config.eula.lib.helpers) list-to-attrs;
  inherit (config.eula.lib.options) mkOpt;
  cfg = config.eula.modules.services.impermanence;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];

  options.eula.modules.services.impermanence = {
    enable = mkOpt types.bool false;
    root = mkOpt types.str "/persist";
    dirs = mkOpt (types.listOf types.str) [];
    files = mkOpt (types.listOf types.str) [];
  };

  config = mkIf config.eula.modules.services.impermanence.enable {
    security.sudo.extraConfig = "Defaults lecture=never"; # avoid getting lectured on rollback
    programs.fuse.userAllowOther = mkDefault true; # allow all users to access persistent fs
    environment.persistence.${cfg.root} = {
      enable = true;
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections/"
        "/etc/ssh"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/backlight/"
      ]
      ++ cfg.dirs;
      files = cfg.files;
    };
  };
}
