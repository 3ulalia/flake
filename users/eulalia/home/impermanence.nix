{ ... } : {

  config.eula.modules.home-manager.impermanence = {
    enable = true;
    directories = [
      "flake"
      "repos"
      ".config/Signal"
    ];
  };

}
