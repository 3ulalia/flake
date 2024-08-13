{
  description = "eula's system configuration (in a flake!)";

  inputs = {
    # not cool enough for unstable (yet)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # home-manager (a regañadientes)
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

    niri.url = "github:sodiboo/niri-flake"; # TODO stop the madness

  };

  outputs = inputs @ { 
    # list of outputs goes here
    self,
    nixpkgs,
    home-manager,
    ...
 }: let
      bootstrap = import ./bootstrap.nix {inherit inputs; lib = nixpkgs.lib;};
    in {
      # nixosConfigurations: {hostName : nixosHost}
      # nixosHosts are generated with nix(-darwin, pkgs).lib.(darwin, nixos)System
      #   which is called on an attribute set containing a `system` attribute and a `modules` list.    
      nixosConfigurations = bootstrap.generate-systems ./hosts [./toplevel.nix];
    };
  }
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#a
#A
#A
#a
#a
#A
#a
#a
