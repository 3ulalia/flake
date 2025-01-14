{pkgs, inputs, ...}: {
  home.packages = [
    pkgs.pavucontrol
    pkgs.vesktop
    pkgs.signal-desktop
    pkgs.remmina # TODO remove
  ];
}
