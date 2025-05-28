{
  lib,
  config,
  pkgs,
  ...
}: let
  oauth2-endpoints = {
    "outlook.office365.com" = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
  };

  secrets = config.eula.extras.read-sops ../../../secrets/eval-secrets.nix;
  construct-email = {
    name,
    flavor ? "plain",
    primary ? false,
    check-time ? "1m",
    thread ? true,
    oauth2 ? false,
    ae-enable ? true,
  }: rec {
    realName = secrets.email.${name}.realname;
    address = secrets.email.${name}.address;
    userName =
      if (flavor != "plain")
      then address
      else builtins.elemAt (lib.splitString "@" address) 0;
    passwordCommand = "cat ${config.sops.secrets."email/${name}/password".path}";
    inherit primary flavor;
    aerc = rec {
      enable = ae-enable;
      imapAuth =
        if oauth2 && (flavor == "outlook.office365.com")
        then "xoauth2"
        else if oauth2
        then "oauthbearer"
        else null;
      smtpAuth = imapAuth;
      imapOauth2Params =
        if oauth2
        then {
          client_id = "9e5f94bc-e8a4-4e73-b8be-63364c29d753"; # thunderbird client_id
          #scope = null; # TODO ?
          token_endpoint = oauth2-endpoints.${flavor};
        }
        else null;
      smtpOauth2Params = imapOauth2Params;
      extraAccounts = {
        use-gmail-ext = flavor == "gmail.com";
        check-mail = check-time;
        default = "INBOX";
      };
      extraConfig.ui = {
        threading-enabled = thread;
        force-client-threads = thread;
        show-thread-context = thread;
        reverse-thread-order = thread;
        dirlist-tree = true;
      };
    };
    # should be overridden by anything trying to set the IMAP host; this is for "plain" accounts that use IMAP
    imap.host = lib.mkOverride 5000 "mail.${builtins.elemAt (lib.splitString "@" address) 1}";
    # security!
    imap.port = lib.mkDefault 993;
    # same as above; anything trying to set the SMTP host will override this
    smtp.host = imap.host;
    # security!!
    smtp.port = lib.mkDefault 465;
  };
in {
  accounts.email.accounts = {
    personal = construct-email {
      name = "personal";
      flavor = "gmail.com";
      primary = true;
    };
    school = construct-email {
      name = "school";
      flavor = "outlook.office365.com";
      oauth2 = true;
    };
    professional = construct-email {name = "professional";};
  };

  sops.secrets =
    builtins.foldl'
    (x: y: x // y)
    {}
    (
      map
      (x: {
        "email/${x}/password" = {};
      })
      ["personal" "school" "professional"]
    );

  programs.aerc.enable = true;
  programs.aerc.extraConfig = {
    general.unsafe-accounts-conf = true; # TODO
    filters = {
      "text/plain" = "colorize";
      "text/html" = "html | colorize";
    };
    hooks = {
      mail-received = "notify-send -t 5000 -a aerc \"[$AERC_ACCOUNT] from $AERC_FROM_NAME\" \"$AERC_SUBJECT\"";
    };
  };
  home.packages = [pkgs.dante pkgs.w3m];
}
