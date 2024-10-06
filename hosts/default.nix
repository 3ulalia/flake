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
  inputs,
  pkgs,
  pkgs-7e2fb8e,
  ...
} : 
  {

    imports = [
      ../users # all hosts will import the default user settings
      inputs.home-manager.nixosModules.home-manager # all hosts will use home-manager
    ];

    # TODO cachix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking = {
      networkmanager.enable = true; # nixos without internet seems silly
      wireless = {
	extraConfig = ''
	  openssl_ciphers=DEFAULT@SECLEVEL=0
	'';
      };
    };

    i18n.defaultLocale = "en_US.UTF-8";

    # time.timeZone = "Europe/Madrid"; # close enough
    time.timeZone = "America/New_York"; # ditto

    system.stateVersion = "23.11";
    
    environment.systemPackages = with pkgs; [vim curl]; # bare necessities

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (import ../overlays/grub2) # TODO module
      inputs.niri.overlays.niri # TODO this does not go here
      (self: super: { wpa_supplicant = pkgs-7e2fb8e.wpa_supplicant; } )
    ];
  }
