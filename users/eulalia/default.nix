{
  config,
  pkgs,
  ...
} : 
  {
    home.username = "eulalia";
    home.homeDirectory = "/home/eulalia";

    home.packages = [];

    home.stateVersion = "";

    programs.home-manager.enable = true;
  }
