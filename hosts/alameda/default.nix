# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  nix.settings = {
    substituters = [ "https://cache.soopy.moe" ];
    trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
  };

  users.groups = {
    plugdev = { };
  };
  hardware = {

    firmware = [
      (pkgs.stdenvNoCC.mkDerivation (final: {
        name = "brcm-firmware";
        src = ./firmware/brcm;
        installPhase = ''
          mkdir -p $out/lib/firmware/brcm
          cp ${final.src}/* "$out/lib/firmware/brcm"
        '';
      }))
    ];

    apple-t2.kernelChannel = "latest";

    apple.touchBar.enable = false;
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  programs = {
    nix-ld.enable = true;
  };
  boot = {

    initrd.systemd.enable = true;
    loader = {
      # Bootloader.

      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";

      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = true;
    };
  };
  services = {

    mbpfan.enable = true;
    mbpfan.aggressive = true;

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    udisks2.enable = true;

    thermald.enable = true;
    tlp.enable = true;
    # TODO change these
    tlp.settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      AMDGPU_ABM_LEVEL_ON_BAT = 3;
      CPU_MAX_PERF_ON_BAT = 50;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
      RADEON_DPM_STATE_ON_BAT = "battery";

      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_BAT = "auto";
      #RUNTIME_PM_ENABLE="00:14.0"; #  Intel Corporation Cannon Lake PCH USB 3.1 xHCI Host Controller

      #USB_ALLOWLIST="05ac:8102 05ac:8103 05ac:8302 05ac:8262 05ac:8514";
    };
  };
  systemd = {

    targets = {
      network-online.wantedBy = lib.mkForce [ ];
    };
    services = {
      systemd-udev-settle.enable = false;
      NetworkManager-wait-online.enable = false;
      NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

    };

  };
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "32768";
    }
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "32768";
    }
  ];
  networking = {
    interfaces = {

      "wlp5s0".useDHCP = true;
      "wlp5s0".wakeOnLan.enable = false;

      "enp4s0f1u1".wakeOnLan.enable = false;
      "enp4s0f1u1".useDHCP = false;
    };

    dhcpcd.wait = "if-carrier-up";
    networkmanager.unmanaged = [ "enp4s0f1u1" ];
    networkmanager.wifi.scanRandMacAddress = false;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    cpufreq = {
      min = 800000;
      max = 1500000;
    };
  };
  eula = {
    modules = {
      services = {
        #eula.modules.services.miracast.enable = true;
        ssh.enable = true;

        disko = {
          enable = true;
          disko-config = ./disko.nix;
          needed-for-boot = [
            "/persist"
            "/var/log"
            "/efi"
          ];
        };
        hibernate = {
          enable = true;
          resume-offset = 533760;
        };

      };
      nixos = {

        users = {
          eulalia = {
            privileged = true;
            sops.enable = true;
            extraGroups = [
              "docker"
              "audio"
              "plugdev"
            ];
          };
        };

        bluetooth.enable = true;
        audio.enable = true;
      };
    };
  };

  virtualisation.docker.enable = true;

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
