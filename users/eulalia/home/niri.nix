{
  config,
  osConfig,
  lib,
  pkgs,
  ...
} : {

  # TODO make this cleaner

  config = {

  eula.modules.home-manager.niri.enable = true;
  eula.modules.home-manager.niri.pkg = pkgs.niri-unstable;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
    size = 28;
  };

  programs.niri.settings = {
    spawn-at-startup = [
      {command = ["swww-daemon"];}
      {command = ["wpaperd"];} # TODO remove on merge of https://github.com/nix-community/home-manager/pull/5833
      {command = ["mako"];}
    ];

    prefer-no-csd = true;

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
 	    "Mod+Space".action = spawn "sh" "-c" "if pidof -qx 'fuzzel'; then kill $(pidof fuzzel); else fuzzel; fi";
	  }
	  {
	    "Mod+W".action = close-window;
	    "Mod+Return".action = center-column;
	    "Mod+Shift+Return".action = maximize-column;
	  }
	  {
	    "Mod+Shift+Q".action = quit;
	    "Mod+Shift+L".action.spawn = ["swaylock"] ++ config.eula.modules.home-manager.swaylock-effects.spawn-command;
	  }
	  {
	    "XF86MonBrightnessDown".action = spawn "brightnessctl" "set" "10%-";
	    "XF86MonBrightnessUp".action = spawn "brightnessctl" "set" "+10%";
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
	    "Super+9".action = consume-or-expel-window-left;
	    "Super+0".action = consume-or-expel-window-right;
	  }
	  {
	    "Mod+Print".action = screenshot;
	    "Mod+Shift+Print".action = screenshot-window;
	  }
	  (binds {
	    suffixes."L" = "column-right";
	    suffixes."H" = "column-left";
	    suffixes."J" = "window-down";
	    suffixes."K" = "window-up";
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
            prefixes."Mod+Shift" = "move-window-to";
            prefixes."Mod+Ctrl" = "move";
	  })
        ];
    };
  };
}
