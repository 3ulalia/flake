{
  pkgs,
  ...
} : 
  {
    cryptHomeLuks = null; # TODO: LUKS

    description = "eulalia";

    extraGroups = [ "networkmanager" "wheel" ];

    isNormalUser = true;

    #packages = import ./packages.nix {inherit pkgs;}; # TODO: abstract this out, since this will be true for all users

    #shell = pkgs.zsh;
  }
