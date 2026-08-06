{ ... }: {
  config.eula.modules.home-manager.impermanence = {
    enable = true;
    directories = [
      "flake"
      "repos"
      "dj"
      ".config/Signal"
      ".Xilinx"
      ".config/xilinx"
    ];
  };
}
