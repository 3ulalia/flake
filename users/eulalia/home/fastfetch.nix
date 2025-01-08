{ ... } : {

  programs.fastfetch = {
    enable = true;
    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "host"
        {
          type = "kernel";
          format = "{release}";
        }
        "uptime"
        {
          type = "command";
          key = "Uptime";
          text = "echo $(($(($(date +%s) - 1707777777)) / 60 / 60 / 24)),$((($(($(date +%s) - 1707777777)) / 60 / 60) % 24)),$((($(($(date +%s) - 1707777777)) / 60) % 60))";
          format = "{#cyan}{1~0,3} days, {#magenta}{1~4,6} hours, {#white}{1~7} mins"; 
        }
        "packages"
        "shell"
        "de"
        "terminal"
        "cpu"
        {
            type = "gpu";
            key = "GPU";
        }
        {
            type = "memory";
            format = "{} / {}";
        }
        "btrfs"
        "locale"
        "break"
        "colors"
      ];
    };
  };
}
