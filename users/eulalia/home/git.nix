{
  config,
  ...
}: {
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
  
  programs.gh.settings.git_protocol = "ssh";

  sops.secrets = {
    "git-config/gh-per" = {};
    "git-config/gh-pro" = {};
    "git-config/gh-sch" = {};
  };
}
