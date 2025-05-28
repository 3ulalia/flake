{pkgs, ...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = [
    pkgs.julia-mono
  ];
}
