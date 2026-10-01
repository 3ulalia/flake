{ pkgs, ... }: {

  home.packages = [
    pkgs.pavucontrol # TODO modularize
  ];
  eula.modules.home-manager = {
    discord.enable = true;
    mc.enable = false;
    signal.enable = true;
    vmware.enable = true;
    claude.enable = false;
  };

}
