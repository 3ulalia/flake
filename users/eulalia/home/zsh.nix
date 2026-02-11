{ ... }:
{
  programs.zsh = {
    history = {
      extended = true;
      ignoreSpace = true;
      # https://github.com/nix-community/impermanence/issues/233
      # path = "$HOME/.local/share/zsh/.zsh_history";
    };
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    setOptions = [
      "NO_HIST_SAVE_BY_COPY"
    ];
  };

  eula.modules.home-manager.impermanence.files = [
    ".zsh_history"
  ];

  /*
      programs.atuin = {
      enable = true;
      enableZshIntegration = true;
    };
  */
}
