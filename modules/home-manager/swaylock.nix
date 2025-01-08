{
  config,
  osConfig,
  lib,
  pkgs,
  ...
} : let 
  inherit (lib) foldl' types mkIf mkOption nameValuePair;
  inherit (osConfig.eula.lib.options) mkOpt mkOptd;
  swc = config.eula.modules.home-manager.swaylock;

  process-color = prefix: colors:
      (lib.mapAttrs'
        (n: v: nameValuePair "${prefix}${if n != "color" then "-${n}" else ""}-color" v)
        colors
      )
    ;

  process-kp-color = prefix: colors: 
    {
      "${prefix}-hl-color" = colors.keypress;
      "caps-lock-${prefix}-hl-color" = colors.caps-lock;
    };

    default-colors = mkOpt (types.submodule { options = {
          color = mkOptd types.str "000000FF" "Sets the color at idle.";
          clear = mkOptd types.str "FFFFFFFF" "Sets the color when the text is cleared.";
          caps-lock = mkOptd types.str "0000FFFF" "Sets the color when Caps Lock is active.";
          ver = mkOptd types.str "00FF00FF" "Sets the color when verifying.";
          wrong = mkOptd types.str "FF0000FF" "Sets the color when invalid.";
        };}) {};

 in {
  options.eula.modules.home-manager.swaylock = {
    enable = mkOpt types.bool false;
    indicator = mkOption { type = types.submodule { options = {
      location = mkOpt (types.enum ["center" "top-left" "top-right" "bottom-left" "bottom-right"]) "center"; # TODO
      radius = mkOpt types.int 75;
      content = mkOption { type = 
        types.submodule { options = {
          text = mkOption { type = types.submodule { options = { # text configuration
            font = mkOpt types.str "Julia Mono";
            font-size = mkOpt types.str "12pt";
            color = default-colors; 
          };};};
          color = default-colors; # plain color
        };};
      };
      colors = mkOpt (types.submodule { options = rec {
        ring = default-colors;
        segments = mkOpt (types.submodule { options = {
          keypress = mkOptd types.str "FFFFFFFF" "Sets the color on keypress.";
          caps-lock = mkOptd types.str "0000FFFF" "Sets the color on keypress when Caps Lock is active.";
        };}) {};
        line = mkOpt (types.attrTag {
          inside = mkOpt (types.submodule {}) {};
          ring = mkOpt (types.submodule {}) {};
          color = default-colors; 
        }) {ring = {};}; 
        separator = mkOpt types.str "FFFFFFFF";
        backspace = segments;
      };}) {};

      text = mkOpt (types.submodule { options = {
        clear = mkOptd types.str "cleared!" "Sets the string displayed when the password is cleared.";
        caps-lock = mkOptd types.str "caps!" "Sets the string displayed when Caps Lock is active.";
        ver = mkOptd types.str "these words..." "Sets the string displayed when the password is being verified.";
        wrong = mkOptd types.str "these words %n are not accepted" "Sets the string displayed when the password is wrong.";
        color = default-colors;
      };}) {};
    };};};

    background = mkOpt (types.submodule { options = {
      color = mkOpt types.str "FFFFFFFF";
      image = mkOpt (types.submodule { options = {
        path = mkOpt types.path null;
        scaling = mkOpt (types.enum ["stretch" "fill" "fit" "center" "tile" "solid_color"]) "fill";
      };}) {};
    };}) {};
  };

  config = mkIf config.eula.modules.home-manager.swaylock.enable {
    eula.modules.home-manager.niri.locker.pkg = pkgs.swaylock;
    programs.swaylock = {
      enable = true;
      settings = foldl' (x: y: x // y) {} [
        {

          daemonize = true;

          font = swc.indicator.content.text.font;
          font-size = swc.indicator.content.text.font-size;
          scaling = swc.background.image.scaling;
          image = swc.background.image.path;

          indicator-radius = toString swc.indicator.radius;

          separator-color = swc.indicator.colors.separator;
        }

        (process-kp-color "bs" swc.indicator.colors.backspace)
        (process-kp-color "key" swc.indicator.colors.segments)


        (process-color "inside" swc.indicator.content.color)
        (
          if swc.indicator.colors.line ? inside
          then {line-uses-inside = true;}
          else if swc.indicator.colors.line ? ring
          then {line-uses-ring = true;}
          else process-color "line" swc.indicator.colors.line.color
        )
        (process-color "ring" swc.indicator.colors.ring)
        (process-color "text" swc.indicator.content.text.color)
      ];
    };
  };
}
