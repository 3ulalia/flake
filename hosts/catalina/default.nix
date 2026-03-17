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

  hardware.apple-t2.kernelChannel = "latest";
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  hardware.apple.touchBar.enable = false;
  programs = {
    nix-ld.enable = true;
    wireshark.enable = true;
    wireshark.package = pkgs.wireshark;

    obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.wlrobs ];
    };
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
    #systemd.network.config = {
    #networkConfig = { DHCP = true; };
    #dhcpV4Config  = { "UseDomains" = true; };
    #dhcpV6Config  = { UseDomains = true; };
    #};
    # TODO: this is a dumb hack. the above (network.config) line should work when this is closed:
    # https://github.com/NixOS/nixpkgs/issues/375960
    # how it's possible that NixOS, an operating system that relies almost entirely on systemd,
    # can have _no one_ assigned to maintain systemd for NixOS astounds me.
    #systemd.network.networks."40-wlp5s0".dhcpV4Config = { UseDNS = true; UseDomains = true;};
    #systemd.network.networks."40-wlp5s0".dhcpV6Config = { UseDNS = true; UseDomains = true;};

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    cloudflare-warp = {
      enable = false;
    };

    udev.packages = [
      pkgs.apio-udev-rules
      (pkgs.callPackage ./xilinx-udev-rules/default.nix { inherit pkgs; })
    ];

    udisks2.enable = true;

    thermald.enable = true;
    tlp.enable = true;
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

    #systemd.services."user@1000".serviceConfig.LimitNOFILE = "32768";
    user.extraConfig = "DefaultLimitNOFILE=32768";
    targets = {
      network-online.wantedBy = lib.mkForce [ ];
    };
    services = {
      systemd-udev-settle.enable = false;
      NetworkManager-wait-online.enable = false;
      NetworkManager-wait-online.wantedBy = lib.mkForce [ ];

      "t2-suspend" = {
        enable = true;
        unitConfig = {
          Description = "Unload and Reload Modules for Suspend and Resume";
          Before = "sleep.target";
          StopWhenUnneeded = "yes";
        };
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = [
            (pkgs.writeShellScript "t2linux-suspend-audio" ''
              set -- $(loginctl list-sessions --no-legend 2>/dev/null | head -n1);
              uid=$2;
              [ -n "$uid" ] || exit 0;
              [ -S "/run/user/$uid/bus" ] || exit 0;
              username=$(id -nu "$uid" 2>/dev/null) || exit 0; XDG_RUNTIME_DIR="/run/user/$uid" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" runuser -u "$username" -- systemctl --user stop pipewire.socket pipewire-pulse.socket pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true
            '')
            ''/run/current-system/sw/bin/env bash -c "echo 0 | tee /sys/class/leds/:white:kbd_backlight/brightness"''
            "/run/current-system/sw/bin/rmmod hci_bcm4377"
            "/run/current-system/sw/bin/rmmod brcmfmac_wcc"
            "/run/current-system/sw/bin/rmmod brcmfmac"
            "/run/current-system/sw/bin/rmmod brcmutil"
            "/run/current-system/sw/bin/rmmod appletbdrm"
            "/run/current-system/sw/bin/rmmod hid_appletb_kbd"
            "/run/current-system/sw/bin/rmmod hid_appletb_bl"
            "/run/current-system/sw/bin/rmmod -f apple-bce"
          ];
          ExecStop = [
            "/run/current-system/sw/bin/modprobe apple-bce"
            "/run/current-system/sw/bin/modprobe brcmutil"
            "/run/current-system/sw/bin/modprobe brcmfmac"
            "/run/current-system/sw/bin/modprobe brmcfmac_wcc"
            "/run/current-system/sw/bin/modprobe hci_bcm4377"
            "/run/current-system/sw/bin/modprobe hid_appletb_bl"
            "/run/current-system/sw/bin/modprobe hid_appletb_kbd"
            "/run/current-system/sw/bin/modprobe appletbdrm"
            "/run/current-system/sw/bin/sleep 2"
            ''/run/current-system/sw/bin/env bash -c "echo 255 | tee /sys/class/leds/:white:kbd_backlight/brightness"''
            (pkgs.writeShellScript "t2linux-resume-audio" ''
              set -- $(loginctl list-sessions --no-legend 2>/dev/null | head -n1);
              uid=$2;
              [ -n "$uid" ] || exit 0; [ -S "/run/user/$uid/bus" ] || exit 0;
              username=$(id -nu "$uid" 2>/dev/null) || exit 0;
              XDG_RUNTIME_DIR="/run/user/$uid" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" runuser -u "$username" -- systemctl --user start pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true
            '')

          ];
          ExecStopPost = [
            "+/run/current-system/sw/bin/systemctl restart systemd-timesyncd"
            "+/run/current-system/sw/bin/systemctl restart upower"
            #"/run/current-system/sw/bin/niri msg action power-off-monitors"
          ];
        };
        wantedBy = [ "sleep.target" ];
      };
      "t2-wakeup-guard" = {
        unitConfig.Description = "Disable problematic ACPI wake sources";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "acpi-source-disable" ''
            grep -q "^ARPT[[:space:]].*\\*enabled" /proc/acpi/wakeup && echo ARPT > /proc/acpi/wakeup || true
            grep -q "^RP01[[:space:]].*\\*enabled" /proc/acpi/wakeup && echo RP01 > /proc/acpi/wakeup || true
            grep -q "^TRP0[[:space:]].*\\*enabled" /proc/acpi/wakeup && echo TRP0 > /proc/acpi/wakeup || true
            grep -q "^TRP1[[:space:]].*\\*enabled" /proc/acpi/wakeup && echo TRP1 > /proc/acpi/wakeup || true
          '';
        };
        wantedBy = [
          "multi-user.target"
          "sleep.target"
        ];
      };

      fs-timestamp = {
        unitConfig.Description = "Write fs timestamp to file";
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
        wantedBy = [ "default.target" ];
      };
    };

    timers.fs-timestamp = {
      unitConfig.Description = "Trigger fs timestamp update";
      timerConfig = {
        OnBootSec = "5m";
        OnUnitInactiveSec = "5m";
        Unit = "fs-timestamp.service";
      };
      wantedBy = [ "timers.target" ];
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
    #networking.useNetworkd = true;
    #systemd.network.networks."40-enp4s0f1u1" = {
    #  linkConfig.RequiredForOnline = "no";
    #  enable = false;
    #};
    networkmanager.unmanaged = [ "enp4s0f1u1" ];
    networkmanager.wifi.scanRandMacAddress = false;

    # wg-quick.interfaces.wg0.configFile = "/home/eulalia/Downloads/documents/creds/11/wireguard/11-one.conf";
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
        impermanence = {

          enable = true;
          dirs = [
            "/lib/firmware/brcm"
            "/var/lib/misc"
            "/var/lib/tailscale/"
          ];
          files = [ "/var/lib/systemd/timesync/clock" ];
        };

        ephemeral-btrfs.enable = true;

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

        tuigreet = {
          enable = true;
          settings = {
            #greeting = "sese! mi toki e toki pona :)";
          };
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
  environment.systemPackages = [
    pkgs.libftdi1
    pkgs.vivado
  ];

  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.nix-xilinx.overlay ];

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
