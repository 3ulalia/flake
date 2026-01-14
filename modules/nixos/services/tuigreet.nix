{
  config,
  eulib,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) foldl' mkIf trace types;
  inherit (eulib.options) mkOpt;

  join = j: l: foldl' (x: y: "${builtins.toString x}${j}${builtins.toString y}") "" l;

  falsy-data = dat: let
    t = builtins.typeOf dat;
  in
    if t == "list"
    then join " " dat
    else if t == "set"
    then join " --env " (lib.mapAttrsToList (a: b: "${builtins.toString a}=${builtins.toString b}") dat)
    else if t == "null"
    then ""
    else if t == "string"
    then "'${dat}'"
    else if t == "bool"
    then
      if dat
      then " "
      else ""
    else builtins.toString dat;

  mk-tuigreet-options = opts:
    lib.foldl'
    (x: y:
      if y.value != ""
      then "--${y.name} ${builtins.toString y.value} ${x}"
      else "${x}")
    ""
    (
      lib.mapAttrsToList
      (a: b: {
        name = a;
        value = falsy-data b;
      })
      opts
    );
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
in {
  options.eula.modules.services.tuigreet = {
    enable = mkOpt types.bool false;
    settings = mkOpt (types.submodule {
      options = {
        /*
          debugPath = mkOpt (types.nullOr types.str) "/tmp/tuigreet.log";
        cmd = mkOpt (types.nullOr types.str) null;
        env = mkOpt types.attrs {};
        sessions = mkOpt (types.listOf types.str) [];
        session-wrapper = mkOpt (types.nullOr types.str) null;
        xsessions = mkOpt (types.listOf types.str) [];
        xsession-wrapper = mkOpt (types.nullOr types.str) null;
        no-xsession-wrapper = mkOpt types.bool false;
        width = mkOpt types.int 80;
        issue = mkOpt types.bool false;
        */
        greeting = mkOpt types.str "sese";
        time = mkOpt types.bool true;
        #time-format = mkOpt types.str "%c";
        remember = mkOpt types.bool true;
        remember-session = mkOpt types.bool true;
        /*
          remember-user-session = mkOpt types.bool true;
        user-menu = mkOpt types.bool false;
        user-menu-min-uid = mkOpt types.int 1000;
        user-menu-max-uid = mkOpt types.int 65536;
        theme = mkOpt (types.nullOr types.str) null;
        asterisks = mkOpt types.bool true;
        asterisks-char = mkOpt types.str "*";
        window-padding = mkOpt types.int 0;
        container-padding = mkOpt types.int 1;
        prompt-padding = mkOpt types.int 1;
        greet-align = mkOpt (types.enum ["left" "center" "right"]) "center";
        power-shutdown = mkOpt types.str "shutdown now";
        power-reboot = mkOpt types.str "reboot";
        power-no-setsid = mkOpt types.bool false;
        kb-command = mkOpt (types.int.between 1 12) 3;
        kb-sessions = mkOpt (types.int.between 1 12) 2;
        kb-power = mkOpt (types.int.between 1 12) 1;
        */
      };
    }) {};
  };

  config = mkIf config.eula.modules.services.tuigreet.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} ${mk-tuigreet-options config.eula.modules.services.tuigreet.settings}";
          #command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
          user = "greeter";
        };
      };
    };
    systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE";
    eula.modules.services.impermanence.dirs = ["/var/cache/tuigreet"];

    # NOTE: the below is stolen from github:sjcobb2022/nixos-config:/hosts/common/optional/greetd.nix
    # this is a life saver.
    # literally no documentation about this anywhere.
    # might be good to write about this...
    # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how
    /*
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
    */
  };
}
