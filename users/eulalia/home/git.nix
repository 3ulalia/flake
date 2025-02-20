{
  config,
  ...
} : let
  secrets = config.eula.extras.read-sops ../../../secrets/eval-secrets.nix;
in {
  programs.git = {
    # sane defaults
    userName = "3ulalia";
    userEmail = "179992797+3ulalia@users.noreply.github.com";
    includes = map 
      (x: 
        {
          path = config.sops.secrets."git-config/gh-${x}".path;
          condition = "hasconfig:remote.*.url:git@gh-${x}*/**";
        }
      )
      ["per" "pro" "sch"]
    ;
    extraConfig.init.defaultBranch = "main";
  };
  
  programs.ssh.matchBlocks = {
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
  };

  sops.secrets = {
    "ssh/gh-per" = {};
    "ssh/gh-sch" = {};
    "ssh/gh-pro" = {};
  };

  programs.gh.settings.git_protocol = "ssh";

  sops.secrets = {
    "git-config/gh-per" = {};
    "git-config/gh-pro" = {};
    "git-config/gh-sch" = {};
  };
}
