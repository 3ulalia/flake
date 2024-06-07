{
  description = "eula's system configuration (in a flake!)";

  inputs = {
    # not cool enough for unstable (yet)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # home-manager (a regañadientes)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
  };

  outputs = inputs @ { 
    # list of outputs goes here
    self,
    nixpkgs,
    home-manager,
    ...
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
