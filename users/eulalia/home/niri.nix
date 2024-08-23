{
  config,
  osConfig,
  lib,
  pkgs,
  ...
} : {
  programs.niri.settings = {
    spawn-at-startup = [
      {command = ["swww-daemon"];}
      {command = ["mako"];}
      #{command = ["dbus-update-activation-environment" "--systemd" "DISPLAY" "WAYLAND_DISPLAY"];}
    ];

    cursor.size = 128;    

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
 	    "Mod+Space".action = spawn "fuzzel";
	    "Mod+W".action = close-window;
	    "Mod+Return".action = maximize-column;
	    "Mod+Minus".action = set-column-width "-10%";
	    "Mod+Equal".action = set-column-width "+10%";
	  }
	  {
	    "Mod+Shift+Q".action = quit;
	    "Mod+Shift+L".action.spawn = ["swaylock"] ++ config.eula.modules.home-manager.swaylock-effects.spawn-command;
	  }
	  {
	    "XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "10%-";
	    "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "+10%";
	  }
	  (binds {
	    suffixes."Right" = "column-right";
	    suffixes."Left" = "column-left";
	    suffixes."Down" = "window-down";
	    suffixes."Up" = "window-up";
	    prefixes."Mod" = "focus";
	    prefixes."Mod+Shift" = "move";
	  })
	  (binds {
	    suffixes."bracketleft" = "first";
	    suffixes."bracketright" = "last";
	    prefixes."Mod" = "focus-column";
	    prefixes."Mod+Shift" = "move-column-to";
	  })
	  (binds {
	    suffixes."Page_Up" = "workspace-up";
	    suffixes."Page_Down" = "workspace-down";
	    prefixes."Mod" = "focus";
            prefixes."Mod+Ctrl" = "move-window-to";
            prefixes."Mod+Shift" = "move";
	  })
        ];
    };
}
