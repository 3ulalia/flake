{
  lib,
  inputs,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit (lib) types mkIf trace;
  mkOpt = osConfig.eula.lib.options.mkOpt;

  sops-config = config.eula.modules.home-manager.sops;
in {

  imports = [inputs.sops-nix.homeManagerModules.sops];

  options.eula = { 
    modules.home-manager.sops = {
      enable = mkOpt types.bool false;
      key-path = mkOpt types.path (config.xdg.configHome + "/sops/age/keys.txt");
      builtins-hack = mkOpt types.bool false;
      i-understand-the-security-implications = mkOpt types.bool false;
      key-type = mkOpt (types.enum ["gnupg" "age" "ssh"]) "age";
    };
    extras.read-sops = mkOpt (types.functionTo types.attrs) (name: {});
  };

  config = mkIf sops-config.enable {
    home.packages = [pkgs.sops];
    sops.age.sshKeyPaths = [(config.home.homeDirectory + "/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED")];
    sops.defaultSopsFile = inputs.self.outPath + "/secrets/secrets.yaml";
    eula.extras.read-sops = (builtins.extraBuiltins.readSops sops-config.key-path);
    eula.modules.home-manager.impermanence.files = [
      sops-config.key-path
    ];
  };
}
