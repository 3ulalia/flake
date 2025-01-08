{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: {
  # TODO make this cleaner

  config = {
    eula.modules.home-manager.niri.enable = true;
    eula.modules.home-manager.niri.pkg = pkgs.niri-unstable;

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 28;
    };

    programs.niri.settings = {
      spawn-at-startup = [
        {command = ["swww-daemon"];}
        {command = ["wpaperd"];} # TODO remove on merge of https://github.com/nix-community/home-manager/pull/5833
        {command = ["mako"];}
        {command = ["avizo-service"];}
        {command = ["nm-applet"];} # TODO make work with options
        {command = ["signal-desktop" "--use-tray-icon" "--ozone-platform-hint=auto"];}
      ];

      prefer-no-csd = true;

      input.touchpad = {
        accel-speed = 0.75;
        accel-profile = "adaptive";
        dwt = true;
        click-method = "clickfinger";
      };

      outputs."eDP-1".scale = 1;

      binds = let
        binds = {
          suffixes,
          prefixes,
          substitutions ? {},
        }: let
          replacer = lib.replaceStrings (lib.attrNames substitutions) (lib.attrValues substitutions);
          format = prefix: suffix: {
            name = "${prefix.key}+${suffix.key}";
            value = let
              actual-suffix =
                if lib.isList suffix.action
                then {
                  action = lib.head suffix.action;
                  args = lib.tail suffix.action;
                }
                else {
                  inherit (suffix) action;
                  args = [];
                };
            in {
              action.${replacer "${prefix.action}-${actual-suffix.action}"} =
                actual-suffix.args;
            };
          };
          pairs = attrs: fn:
            lib.concatMap (key:
              fn {
                inherit key;
                action = attrs.${key};
              }) (lib.attrNames attrs);
        in
          lib.listToAttrs (pairs prefixes (prefix: pairs suffixes (suffix: [(format prefix suffix)])));
      in
        with config.lib.niri.actions; let
          sh = spawn "sh" "-c";
        in
          lib.attrsets.mergeAttrsList [
            {
              "Mod+Tab".action = spawn "alacritty";
              "Mod+Space".action = sh "if pidof -qx 'fuzzel'; then kill $(pidof fuzzel); else fuzzel; fi";
              "Mod+F".action = spawn "firefox";
              "Mod+Shift+F".action = spawn "firefox" "--private-window";
            }
            {
              "Mod+W".action = close-window;
              "Mod+Return".action = center-column;
              "Mod+Shift+Return".action = maximize-column;
              "Mod+Alt+Return".action = fullscreen-window;
            }
            {
              "Mod+Control+Q".action = quit;
              "Mod+Shift+Q".action = sh "${config.eula.modules.home-manager.niri.locker.pkg.pname}";
              "Mod+Shift+Slash".action = show-hotkey-overlay;
            }
            {
              "XF86AudioRaiseVolume" = {
                action = spawn "volumectl" "-u" "up";
                allow-when-locked = true;
              };
              "XF86AudioLowerVolume" = {
                action = spawn "volumectl" "-u" "down";
                allow-when-locked = true;
              };
              "XF86AudioMute" = {
                action = spawn "volumectl" "toggle-mute";
                allow-when-locked = true;
              };
              "XF86AudioMicMute" = {
                action = spawn "volumectl" "-m" "toggle-mute";
                allow-when-locked = true;
              };
            }
            {
              "XF86MonBrightnessDown".action = spawn "lightctl" "down";
              "XF86MonBrightnessUp".action = spawn "lightctl" "up";
              "Shift+XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "2%-";
              "Shift+XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "+2%";
            }
            {
              "Mod+Minus".action = set-column-width "-10%";
              "Mod+Equal".action = set-column-width "+10%";
              "Mod+backslash".action = set-column-width "50%";
              "Mod+Shift+backslash".action = set-window-height "50%";
              "Mod+Shift+Minus".action = set-window-height "-10%";
              "Mod+Shift+Equal".action = set-window-height "+10%";
            }
            {
              "Mod+9".action = consume-or-expel-window-left;
              "Mod+0".action = consume-or-expel-window-right;
            }
            (binds {
              suffixes = (builtins.foldl' (x: y: x // y) {} (
                builtins.map (x: {${builtins.toString x} = ["workspace" x];}) (lib.range 1 8)));
              prefixes."Mod" = "focus";
              prefixes."Mod+Shift" = "move-column-to";
            })
            {"Mod+grave".action = focus-workspace-previous;}
            {
              "Mod+Print".action = screenshot;
              "Mod+Shift+Print".action = screenshot-window;
            }
            (binds {
              suffixes."L" = "column-right-or-to-monitor-right";
              suffixes."J" = "column-left-or-to-monitor-left";
              suffixes."K" = "window-down-or-to-workspace-down";
              suffixes."I" = "window-up-or-to-workspace-up";
              prefixes."Mod+Shift" = "move";
            })
            (binds {
              suffixes."bracketleft" = "first";
              suffixes."bracketright" = "last";
              prefixes."Mod" = "focus-column";
              prefixes."Mod+Shift" = "move-column-to";
            })
            (binds {
              suffixes."L" = "column-or-monitor-right";
              suffixes."J" = "column-or-monitor-left";
              suffixes."K" = "window-or-workspace-down";
              suffixes."I" = "window-or-workspace-up";
              prefixes."Mod" = "focus";
            })
            (binds {
              suffixes."Page_Up" = "workspace-up";
              suffixes."Page_Down" = "workspace-down";
              prefixes."Mod" = "focus";
              prefixes."Mod+Shift" = "move-window-to";
              prefixes."Mod+Ctrl" = "move";
            })
          ];
    };
  };
}
