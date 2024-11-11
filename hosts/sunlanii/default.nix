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
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
    ];

  # This shouldn't be needed, but might be :3
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.loader.systemd-boot.configurationLimit = 5;

  eula.modules.services.lanzaboote = {
    enable = true;
    dismiss-warning = true;
  };

  eula.modules.services.hibernate = {
    enable = true;
    resume-device = "/dev/disk/by-label/nixos";
    resume-offset = 533760;
  };

  networking.hostName = "sunlanii"; # Define your hostname.

  eula.modules.nixos.users = {
    eulalia = {
      privileged = (trace "now evaluating thinkpad configuration!" true); 
      extraGroups = ["audio"];
    };
  };

  eula.modules.services.disko = {
    enable = true;
    disko-config = ./disko.nix;
    needed-for-boot = ["/persist" "/var/log"];
  };

  eula.modules.nixos.bluetooth.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udisks2.enable = true;

  services.fwupd.enable = true;

  services.tailscale.enable = true;

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
