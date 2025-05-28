{
  description = "eula's system configuration (in a flake!)";

  nixConfig = {
    extra-substituters = ["https://cache.soopy.moe"]; # used for t2linux
    extra-trusted-public-keys = ["cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="];
  };

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
      url = "github:sodiboo/niri-flake"; # TODO stop the madness
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
    bootstrap = import ./bootstrap.nix {
      inherit inputs;
      lib = nixpkgs.lib;
    };
  in
    flake-utils.lib.eachDefaultSystem (system: {
      checks = {
        format =
          nixpkgs.legacyPackages.${system}.runCommandNoCCLocal "format" {
            src = ./.;
            nativeBuildInputs = with nixpkgs.legacyPackages.${system}; [alejandra];
          } ''
            alejandra .
            mkdir "$out"
          '';
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    })
    //
    # nixosConfigurations: {hostName : nixosHost}
    # nixosHosts are generated with nix(-darwin, pkgs).lib.(darwin, nixos)System
    #   which is called on an attribute set containing a `system` attribute and a `modules` list.
    {
      nixosConfigurations =
        bootstrap.hosts.generate-systems
        ./hosts
        {inherit bootstrap inputs;}
        [./toplevel.nix];
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

