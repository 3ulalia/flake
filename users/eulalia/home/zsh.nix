{
  ...
}: {

  programs.zsh = {
    history.ignoreSpace = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
