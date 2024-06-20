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
  };

  outputs = inputs @ { 
    # list of outputs goes here
    self,
    nixpkgs,
    home-manager,
    ...
 }: let
      inherit (self) outputs; # required so we can pass it through to our lib
      inherit (lib.eula) generateSystem mapModules mapHosts;

      lib = nixpkgs.lib.extend ( # extend the given `lib` with our helpers
        self: super: {
          eula = import ./lib {
            inherit inputs outputs;
            lib = self;
          };
        }
      );

    in {
      # nixosConfigurations: {hostName : nixosHost}
      # nixosHosts are generated with nix(-darwin, pkgs).lib.(darwin, nixos)System
      #   which is called on an attribute set containing a `system` attribute and a `modules` list.
      nixosConfigurations = map generateSystem (mapHosts import ./hosts);
    };
  }