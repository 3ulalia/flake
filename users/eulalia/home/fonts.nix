{ config, pkgs,  ... } : {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      #monospace = ["ZedMono Nerd Font Mono"];
      #sansSerif = ["DejaVu Sans Mono"];
    };
  };
  home.packages = [
    pkgs.nerd-fonts.zed-mono
    pkgs.nerd-fonts.space-mono
    pkgs.plemoljp-nf
  ];
}
