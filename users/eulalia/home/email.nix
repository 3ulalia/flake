{
  lib,
  config,
  ...
} : 
let
  construct-email = {name, primary ? false, tb-enable ? true} : rec {
    realName = builtins.readFile config.sops.secrets."email/${name}/realname".path;
    address = builtins.readFile config.sops.secrets."email/${name}/address".path;
    userName = builtins.elemAt 0 (lib.splitString "@" address);
    inherit primary;
    passwordCommand = "cat ${config.sops.secrets."email/${name}/password".path}";
    thunderbird.enable = tb-enable;
  };
in {
  accounts.email.accounts = {
    personal = construct-email {name = "personal"; primary = "true";};
    school = construct-email {name = "school";};
    professional = construct-email {name = "professional";};
  };
}
