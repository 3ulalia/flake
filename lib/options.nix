{lib, ...}: let
  inherit (lib) mkOption;
in {
  config.eula.lib.options = {
    mkOpt = type: default: mkOption {inherit type default;};

    mkOptd = type: default: description: mkOption {inherit type default description;};
  };
}
