{
  description = "eula's system configuration (in a flake!)";

  inputs = {
    # not cool enough for unstable (yet)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; 
    # window manager
    niri.url = "github:sodiboo/niri-flake/main";
    # hardware bodges
    nixos-hardware.url = "github:NixOS/nixos-hardware/main";
  };

  outputs = inputs @ { 
    # list of outputs goes here
    self,
    nixpkgs,
    niri,
    nixos-hardware
  }: let
    # define helpers that we'll use to set up our environment
    
    system = "x86_64-linux";
    
    # lets us compose an input pkgs with our custom overlays
    mkPkgs = pkgs: extraOverlays:
      import pkgs {
        inherit system;
	config.allowUnfree = true;
	overlay = extraOverlays;
      };
    
    pkgs = mkPkgs nixpkgs [];

    in {

	nixosModules = {dotfiles = import ./.;} // mapModulesRec ./modules import;

	nixosConfigurations = mapHosts ./hosts {};

    };
  };
