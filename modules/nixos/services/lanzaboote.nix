/*
Many thanks to Jon Seager for his excellent post on how to enable Secure Boot on NixOS.

https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde/
*/
{
  config,
  eulib,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) length pathExists;
  inherit (lib) mkOption mkForce mkIf mkAliasDefinitions trace types;
  inherit (eulib.helpers) list-to-attrs;
  inherit (eulib.options) mkOpt;
in {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  options.eula.modules.services.lanzaboote = {
    enable = mkOpt types.bool false;
    dismiss-warning = mkOpt types.bool false;
  };

  config = mkIf config.eula.modules.services.lanzaboote.enable {
    environment.systemPackages = [pkgs.sbctl];

    boot.bootspec.enable = true;

    boot.loader.systemd-boot.enable = mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    boot.initrd.systemd.enable = true; # TODO: look into clevis

    assertions = [
      {
        assertion = !config.boot.loader.grub.enable;
        message = "lanzaboote is incompatible with GRUB for now (see https://github.com/nix-community/lanzaboote/issues/29)";
      }
    ];

    warnings =
      if (config.eula.modules.services.lanzaboote.enable && !config.eula.modules.services.lanzaboote.dismiss-warning)
      then [
        ''
          lanzaboote configuration is not entirely handled by the NixOS module.
          to complete configuration, do the following:

            > sudo sbctl create-keys
              (this will create Secure Boot keys in /etc/secureboot)
              (if you use impermanence, make sure to persist this directory!)
            > sudo nixos-rebuild switch --flake path/to/your/flake#your-hostname
              (don't worry about it reporting kernel images as unsigned for now)
            > reboot
              * enter UEFI interface
              * enable Secure Boot
                * ASUS: you may need to set "OS Type" to "Windows UEFI Mode"
              * clear preloaded Secure Boot keys
                * this may be called "Enter Setup Mode" or "Erase Platform Keys"
                * do NOT select "Clear All Secure Boot Keys"!!!
              * set a UEFI password (otherwise Secure Boot can just be disabled)
              * save and exit
            > sudo sbctl enroll-keys --microsoft
              (the --microsoft option adds their keys, just in case)
            > reboot
            > bootctl status
              (this should display "Secure Boot: enabled")

          in addition, if you want to enable TPM unlock of your root partition,
          do the following:

            > sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/your/device/here

          once you're _sure_ this all works, set:
            eula.modules.services.lanzaboote.dismiss-warning = true;
          to hide this warning.
        ''
      ]
      else []; # ++ [if cond then [warning] else [nonwarning]]
  };
}
