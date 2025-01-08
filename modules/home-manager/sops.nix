{
  lib,
  inputs,
  config,
  osConfig,
  self,
  ...
}: let
  inherit (lib) types mkIf;
  mkOpt = osConfig.eula.lib.options.mkOpt;

  sops-config = config.eula.modules.home-manager.sops;
in {

  imports = [inputs.sops-nix.homeManagerModules.sops];

  options.eula.modules.home-manager.sops = {
    enable = mkOpt types.bool false;
    key-path = mkOpt types.path config.xdg.configHome + "sops/age/keys.txt";
    key-type = mkOpt (types.enum ["gnupg" "age" "ssh"]) "age";
  };

  config = mkIf sops-config.enable {
    sops = {
      defaultSopsFile = self.outPath + "secrets/secrets.yaml";
      
      age = {
        keyFile = config.xdg.configHome + "sops/age/keys.txt";
        sshKeyPaths = [(config.home.homeDirectory+"/.ssh/id_ed25519")];
      };

      secrets.${"passwords/"+config.home.username} = {
        path = sops-config.key-path;
        neededForUsers = true;
      };
    };  
  };
}
