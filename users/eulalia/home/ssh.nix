{ config, secrets, ... }:
{
  programs.ssh = {
    enable = true;
    settings."*".compression = true;
    includes = [ "config.d/*" ];
    settings.explorer = {
      inherit (secrets.ssh.explorer) hostname user;
      identitiesOnly = true;
      identityFile = config.sops.secrets."ssh/gh-per".path;
    };
    # extraConfig = "IdentityFile ${config.home.homeDirectory}/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED";
  };

}
