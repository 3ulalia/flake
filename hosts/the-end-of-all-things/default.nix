# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  lib,
  inputs,
  pkgs,
  ...
}:

let 

inherit (lib) trace;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # This shouldn't be needed, but might be :3
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NOTE: remove if already present in ./hardware-configuration.nix
  boot.kernelModules = [ "applesmc" ];

  # Bootloader.

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "the-end-of-all-things"; # Define your hostname.

  eula.modules.nixos.users = {
    xenia = {
      privileged = (trace "now evaluating ${networking.hostname} configuration!" true); 
      extraGroups = ["audio"];
    };
  };

  eula.modules.services.disko = {
    enable = true;
    disko-config = ./disko.nix;
    needed-for-boot = ["/persist" "/var/log"];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udisks2.enable = true;

  services.fwupd.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
