{
  lib,
  eulib,
  inputs,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) types mkIf;
  mkOpt = eulib.options.mkOpt;
  cfg = osConfig.eula.modules.nixos.users.${config.home.username}.sops;
  key-path =
    if cfg.key-path == null then
      "/home/${config.home.username}/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED"
    else
      key-path;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options.eula.secrets = mkOpt types.attrs { };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.sops
      pkgs.ssh-to-age
    ];
    sops.age.sshKeyPaths = [ key-path ];
    sops.defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";
    eula.secrets = builtins.readFile ../../secrets/eval-secrets.nix;
  };
}
