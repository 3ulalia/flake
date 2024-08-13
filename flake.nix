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
      inherit (self) outputs; # required so we can pass it through to our lib
      bootstrap = import ./bootstrap.nix {inherit inputs outputs; lib = nixpkgs.lib;};
    in {

      nixosModules = import ./lib {lib = nixpkgs.lib;};

      # nixosConfigurations: {hostName : nixosHost}
      # nixosHosts are generated with nix(-darwin, pkgs).lib.(darwin, nixos)System
      #   which is called on an attribute set containing a `system` attribute and a `modules` list.    
      nixosConfigurations = bootstrap.helpers.list-to-attrs (map bootstrap.hosts.generateSystem (bootstrap.hosts.mapHosts bootstrap.hosts.importHost ./hosts));

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
