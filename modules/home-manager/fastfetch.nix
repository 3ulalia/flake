{
  config,
  eulib,
  lib,
  ...
}: 
let
  inherit (lib) mkIf types;
  inherit (eulib.options) mkOpt;
  cfg = config.eula.modules.home-manager.fastfetch;
in {
  options.eula.modules.home-manager.fastfetch = {
    enable = mkOpt types.bool true;
  };

  config.programs.fastfetch = mkIf cfg.enable {
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
          # NOTE: replacing '%02d' with '%2d' makes the rendering cleaner - 08 -> 8. do i care?
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
