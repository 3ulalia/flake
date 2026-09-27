{ config, secrets, ... }:
{
  programs = {
    git = {
      # sane defaults
      settings = {
        user = {
          name = "3ulalia";
          email = "179992797+3ulalia@users.noreply.github.com";
        };
        init.defaultBranch = "main";
      };
      includes =
        map
          (x: {
            path = config.sops.secrets."git-config/gh-${x}".path;
            condition = "hasconfig:remote.*.url:git@gh-${x}*/**";
          })
          [
            "per"
            "pro"
            "sch"
          ];
    };

    ssh.settings = {
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
        hostname = secrets.git.school.hostname;
        identityFile = config.sops.secrets."ssh/gh-per".path;
        identitiesOnly = true;
      };
      gitlab-professional = {
        host = "gl-pro";
        hostname = "gitlab.com";
        identityFile = config.sops.secrets."ssh/gl-pro".path;
        identitiesOnly = true;
      };
      gitea-nxc = {
        host = "gt-nxc";
        hostname = "git.immutable-byte.de";
        identityFile = config.sops.secrets."ssh/gt-nxc".path;
        identitiesOnly = true;
      };
    };

    gh.settings.git_protocol = "ssh";
  };

  sops.secrets = {
    "ssh/gh-per" = { };
    "ssh/gh-sch" = { };
    "ssh/gh-pro" = { };
    "ssh/gl-pro" = { };
    "ssh/gt-nxc" = { };
    "git-config/gh-per" = { };
    "git-config/gh-pro" = { };
    "git-config/gh-sch" = { };
    "git-config/gl-pro" = { };
    "git-config/gt-nxc" = { };
  };
}
