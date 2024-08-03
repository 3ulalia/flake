{
  lib,
  ...
} : 
  let 
    inherit (lib) types mkOption;
  in {
    mkOpt = type: default: mkOption {inherit type default;};

    mkOptd = type: default: description: mkOption {inherit type default description;};
  }