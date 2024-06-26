/**
  The purpose of this file is to collect as many machine-wide configurations that should
  apply to all machines managed under this flake as possible.

  This includes network enablement, basic packages, internationalization, and time zones,
  as well as more complex settings like nix daemon settings and cachix configurations.

  For user-specific options, edit your user's file in users/<you> (or make your own!)

  Note: users can override these settings as they would like, and their settings will
  take precedence. This merely sets "sane defaults" on a machine-wide level. For example: 
  default i18n values, default time zones, etc.
 */

{ 
  pkgs,
  inputs,
  ...
} : 
  {
    

    networking = {
      networkmanager.enable = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";

    time.timeZone = "Europe/Madrid"; # close enough

    

  }