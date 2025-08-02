{
  description = "eula's system configuration (in a flake!)";

  inputs = {
    # officially cool enough for unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager (a regañadientes)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "git+file:///home/eulalia/repos/niri-flake/"; # TODO stop the madness
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

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

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    eulalia-nvim = {
      url = "git+file:///home/eulalia/repos/eulalia-nvim/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-utils,
    nixpkgs,
    #  lix-module,
    sops-nix,
    ...
  }: let
    eulib = import ./lib {
      lib = nixpkgs.lib;
    };
  in
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    })
    //
    # nixosConfigurations: {hostName : nixosHost}
    # nixosHosts are generated with nix(-darwin, pkgs).lib.(darwin, nixos)System
    #   which is called on an attribute set containing a `system` attribute and a `modules` list.
    {
      nixosConfigurations =
        eulib.hosts.generate-systems
        ./hosts
        {inherit eulib inputs;}
        [./hosts ./modules/nixos ./users];
    }; #lix-module.nixosModules.default];};
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

