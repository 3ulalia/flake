{
  pkgs,
  ...
} : 
  {
    cryptHomeLuks = null; # TODO: LUKS

    description = "eulalia";

    extraGroups = [ "networkmanager" "wheel" ];

    isNormalUser = true;

    pkgs = import ./packages.nix; # TODO: abstract this out, since this will be true for all users

    shell = pkgs.zsh;
  }