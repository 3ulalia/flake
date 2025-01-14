{ inputs, pkgs, config, ... } : {
    nixpkgs.overlays = [
      inputs.eulalia-nvim.overlays.default
    ];
    home.packages = [ pkgs.nvim-pkg ];
  }
