# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) trace;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
      name = "brcm-firmware";
      src = ./firmware/brcm;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp ${final.src}/* "$out/lib/firmware/brcm"
      '';
    }))
  ];

  hardware.apple.touchBar.enable = false;
  # Bootloader.

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/efi";
  };

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.enable = true;

  eula.modules.services.impermanence = {
    enable = true;
    dirs = ["/lib/firmware/brcm" "/var/lib/misc"];
    files = ["/var/lib/systemd/timesync/clock"];
  };
  eula.modules.services.ephemeral-btrfs.enable = true;

  services.mbpfan.enable = true;
  services.mbpfan.aggressive = true;

  networking.interfaces."wlp5s0".wakeOnLan.enable = false;
  networking.interfaces."enp4s0f1u1" = {
    wakeOnLan.enable = false;
    useDHCP = false;
  };
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.dhcpcd.wait = "if-carrier-up";
  systemd.targets.network-online.wantedBy = lib.mkForce [];
  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [];
  networking.useNetworkd = true;
  systemd.network.networks."enp4s0f1u1" = {
    linkConfig.RequiredForOnline = "no";
    enable = false;
  };
  networking.networkmanager.unmanaged = [ "enp4s0f1u1" ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    cpufreq = {
      min = 800000;
      max = 1500000;
    };
    resumeCommands = "/run/current-system/sw/bin/niri msg action power-off-monitors";
  };

  #eula.modules.services.miracast.enable = true;
  eula.modules.services.ssh.enable = true;

  eula.modules.nixos.users = {
    eulalia = {
      privileged = true;
    };
  };

  eula.modules.services.disko = {
    enable = true;
    disko-config = ./disko.nix;
    needed-for-boot = ["/persist" "/var/log" "/efi" ];
  };

  eula.modules.nixos.bluetooth.enable = true;
  eula.modules.nixos.audio.enable = true;
  eula.modules.services.hibernate = {
    enable = true;
    resume-offset = 533760;
  };

  eula.modules.services.tuigreet = {
    enable = true;
    settings = {
      #greeting = "sese! mi toki e toki pona :)";
    };
  };  

  services.udisks2.enable = true;

  services.thermald.enable = true;
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_BAT="power";
    PLATFORM_PROFILE_ON_BAT="low-power";
    CPU_BOOST_ON_BAT=0;
    CPU_HWP_DYN_BOOST_ON_BAT=0;
    AMDGPU_ABM_LEVEL_ON_BAT=3;
    CPU_MAX_PERF_ON_BAT=50;

    START_CHARGE_THRESH_BAT0=75;
    STOP_CHARGE_THRESH_BAT0=80;

    INTEL_GPU_MIN_FREQ_ON_BAT=350;
    INTEL_GPU_MAX_FREQ_ON_BAT=750;
    INTEL_GPU_BOOST_FREQ_ON_BAT=800;

    RADEON_DPM_PERF_LEVEL_ON_BAT="low";
    RADEON_DPM_STATE_ON_BAT="battery";

    PCIE_ASPM_ON_BAT="powersupersave";

    RUNTIME_PM_ON_BAT="auto";
    #RUNTIME_PM_ENABLE="00:14.0"; #  Intel Corporation Cannon Lake PCH USB 3.1 xHCI Host Controller

    #USB_ALLOWLIST="05ac:8102 05ac:8103 05ac:8302 05ac:8262 05ac:8514";
  };

  systemd.services."suspend-fix-t2" = {
    enable = true;
    unitConfig = {
      Description = "Disable and Re-Enable Apple BCE Module (and Wi-Fi)";
      Before = "sleep.target";
      StopWhenUnneeded = "yes";
    };
    serviceConfig = {   
      User = "root";
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = [
        "/run/current-system/sw/bin/rmmod -f apple-bce"
      #  "/run/current-system/sw/bin/modprobe -r brcmfmac"
      #  "/run/current-system/sw/bin/modprobe -r brcmfmac_wcc"
      ];
      ExecStop = [
        "/run/current-system/sw/bin/modprobe apple-bce"
      #  "/run/current-system/sw/bin/modprobe brcmfmac"
      #  "/run/current-system/sw/bin/modprobe brmcfmac_wcc"
      ];
      ExecStopPost = [
        "+/run/current-system/sw/bin/systemctl restart systemd-timesyncd"
        #"/run/current-system/sw/bin/niri msg action power-off-monitors"
      ];
    };
    wantedBy = [ "sleep.target" ];
  };

  systemd.timers.fs-timestamp = {
    unitConfig.Description = "set fs timestamp";
    timerConfig = {
      OnBootSec = "5m";
      OnUnitInactiveSec = "5m";
      Unit = "fs-timestamp.service";
    };
    wantedBy = ["timers.target"];
  };
  systemd.services.fs-timestamp = {
    unitConfig.Description = "write fs timestamp to file";
    serviceConfig = {
      Type = "exec";
      PassEnvironment = "DISPLAY";
      ExecStart = pkgs.writeShellScript "fs-timestamp" ''
        if [[ -e /run/systemd/timesync/synchronized ]]; then
          echo 0 > /var/lib/misc/fs-iter # we're connected; we know that we have the correct timestamp 
        else # we aren't connected; we have to trust the last known sync time
          touch /var/lib/misc/fs-iter # mark the last time we checked for connection 
        fi
      '';
      Restart = "on-failure";
    };
    wantedBy = ["default.target"];
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
