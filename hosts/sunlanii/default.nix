# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  lib,
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

  # Bootloader.
  # boot.loader.systemd-boot.enable = true; # GRUB for the win
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    # useOSProber = true; # this way lies danger
    device = "nodev";

    # 5456-C82D

    extraEntries = ''
      menuentry "Arch Linux (on /dev/nvme0n1p4)" --class arch --class os {
        set gfxpayload=keep
        set gfxmode=auto
        insmod part_gpt
        insmod part_msdos
        echo ""
        echo ""       
        echo ""
        search --no-floppy --fs-uuid --set=root 5456-C82D
        echo "Loading Arch Linux"
        linux /vmlinuz-linux root=/dev/nvme0n1p4 rw loglevel=3 quiet
        echo "Loading initial ramdisk..."
        initrd /initramfs-linux.img
      }
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sunlanii"; # Define your hostname.

  modules.users = [
    {
      name = (trace "now evaluating thinkpad configuration!" "eulalia"); 
      privileged = true;
    }
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

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
