{pkgs, inputs, ...}: {
  home.packages = [
    pkgs.pavucontrol
    pkgs.vesktop
    pkgs.signal-desktop
    #pkgs.neovim # TODO configuration
    inputs."3ulalia-nvim".packages.${builtins.currentSystem}.nvim
    pkgs.remmina # TODO remove
  ];
}
