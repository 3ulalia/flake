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
          text = "echo $(printf '%02d' $((($(($(date +%s) - 1707777777)) / 60) % 60)))$(printf '%02d' $((($(($(date +%s) - 1707777777)) / 60 / 60) % 24)))$(($(($(date +%s) - 1707777777)) / 60 / 60 / 24))";
          format = "{#cyan}{1~4} days, {#magenta}{1~2,4} hours, {#white}{1~0,2} mins"; 
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
