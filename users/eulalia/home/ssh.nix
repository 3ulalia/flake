{
  config,
  ...
}: {
  programs.ssh = {
    enable = true;
    compression = true;
    includes = [ "config.d/*" ];
    matchBlocks = {
      github-personal = {
        host = "gh-per";
        hostname = "github.com";
        identityFile = config.sops.secrets."ssh/gh-per".path;
        identitiesOnly = true;
      };
      github-professional = {
        host = "gh-pro";
        hostname = "github.com";
        identityFile = config.sops.secrets."ssh/gh-pro".path;
        identitiesOnly = true;
      };
      github-school = {
        host = "gh-sch";
        hostname = "github.khoury.northeastern.edu";
        identityFile = config.sops.secrets."ssh/gh-per".path;
        identitiesOnly = true;
      };
    };
  };
  sops.secrets = {
    "ssh/gh-per" = {};
    "ssh/gh-sch" = {};
    "ssh/gh-pro" = {};
  };
}
