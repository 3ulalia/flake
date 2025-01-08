{
  lib,
  config,
  pkgs,
  ...
} : 
let
  construct-email = {name, flavor ? "plain", primary ? false, ae-enable ? true} : rec {
    realName = builtins.readFile config.sops.secrets."email/${name}/realname".path;
    address = builtins.readFile config.sops.secrets."email/${name}/address".path;
    userName = if (flavor != "plain") then address else builtins.elemAt (lib.splitString "@" address) 0;
    passwordCommand = "cat ${config.sops.secrets."email/${name}/password".path}";
    inherit primary flavor;
    aerc = {
      enable = ae-enable;
    };
    # should be overridden by anything trying to set the IMAP host; this is for "plain" accounts that use IMAP
    imap.host = lib.mkOverride 5000 "mail.${builtins.elemAt (lib.splitString "@" address) 1}";
    # security!
    imap.port = lib.mkDefault 993;
    # same as above; anything trying to set the SMTP host will override this
    smtp.host = imap.host;
    # security!!
    smtp.port = lib.mkDefault 587;
  };
in {
  accounts.email.accounts = {
    personal = construct-email {name = "personal"; flavor = "gmail.com"; primary = true;};
    school = construct-email {name = "school"; flavor = "outlook.office365.com";};
    professional = construct-email {name = "professional";};
  };
  sops.secrets = builtins.foldl' 
    (x: y: x // y) 
    {} 
    (map 
      (x: {
        "email/${x}/realname" = {};
        "email/${x}/address" = {};
        "email/${x}/password" = {};
      })
      ["personal" "school" "professional"]
    );
  programs.aerc.enable = true;
  programs.aerc.extraConfig = {
    general.unsafe-accounts-conf = true;
    filters = {
      "text/plain" = "colorize";
      "text/html" = "html | colorize";
    };
  };
  home.packages = [pkgs.dante pkgs.w3m]; 
}
