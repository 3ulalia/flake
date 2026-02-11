{ config, ... }:
let
  secrets = config.eula.extras.read-sops ../../../secrets/eval-secrets.nix;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks."*".compression = true;
    includes = [ "config.d/*" ];
    matchBlocks.explorer = {
      inherit (secrets.ssh.explorer) hostname user;
      identitiesOnly = true;
      identityFile = config.sops.secrets."ssh/gh-per".path;
    };
    # extraConfig = "IdentityFile ${config.home.homeDirectory}/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED";
  };

  # eula.modules.home-manager.impermanence.directories = [ ".ssh" ]; # no longer needed!
}
