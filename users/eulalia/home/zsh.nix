{...}: {
  programs.zsh = {
    history = {
      extended = true;
      ignoreSpace = true;
      # https://github.com/nix-community/impermanence/issues/233
      # path = "$HOME/.local/share/zsh/.zsh_history";
    };
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
  };

  eula.modules.home-manager.impermanence.directories = [
  #   ".local/share/zsh"
  ];

  /*
    programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
  */
}
