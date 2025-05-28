{
  inputs,
  pkgs,
  config,
  ...
}: {
  #    nixpkgs.overlays = [
  #      inputs.eulalia-nvim.overlays.default
  #    ];
  home.sessionVariables.EDITOR = "nvim";
  home.packages = [pkgs.nvim-pkg];
}
