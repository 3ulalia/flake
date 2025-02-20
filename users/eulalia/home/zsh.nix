{
  ...
}: {

  programs.zsh = {
    history.ignoreSpace = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
  };

  eula.modules.home-manager.impermanence.files = [
    ".zsh_history"
  ];

  /*programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };*/

}
