{
  description = "eula's system configuration (in a flake!)";

  inputs = {

    # officially cool enough for unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # maybe someday wpa_supplicant will stop being broken
    nixpkgs-7e2fb8e.url = "github:nixos/nixpkgs/f66cbf3e8e28aeb6903929caf967a498ae49d27e";

    # home-manager (a regañadientes)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

    niri.url = "github:sodiboo/niri-flake"; # TODO stop the madness

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs @ { 
    self,
    nixpkgs,
    nixpkgs-7e2fb8e,
    home-manager,
    disko,
    impermanence,
    lanzaboote,
    ...
 }: let
      bootstrap = import ./bootstrap.nix {inherit inputs; lib = nixpkgs.lib;};
    in {
      # nixosConfigurations: {hostName : nixosHost}
      # nixosHosts are generated with nix(-darwin, pkgs).lib.(darwin, nixos)System
      #   which is called on an attribute set containing a `system` attribute and a `modules` list.    
      nixosConfigurations = bootstrap.hosts.generate-systems ./hosts {inherit bootstrap inputs; pkgs-7e2fb8e = import nixpkgs-7e2fb8e { system = "x86_64-linux"; };} [./toplevel.nix];
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
