/*
https://haseebmajid.dev/posts/2024-07-30-how-i-setup-btrfs-and-luks-on-nixos-using-disko/
https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
*/
let
  mount-options = sv: ["subvol=${sv}" "compress=zstd" "noatime" "space_cache=v2"];
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI System Partition";
              name = "ESP";
              size = "300M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
                mountOptions = ["defaults"];
              };
            };
            macos = {
              label = "macos";
              name = "legacy";
              size = "93.6G";
              type = "AF0A";
              content = {
                type = "filesystem";
                format = "apfs";
                #mountpoint = "/macos";
                #mountOptions = ["vol=1"]; ## TODO
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptid";
                extraOpenArgs = [
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                settings = {
                  allowDiscards = true;
                  # keyFile = ""; # TODO
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos" "-f"]; # TODO
                  subvolumes = {
                    "/boot" = {
                      mountpoint = "/boot";
                      mountOptions = mount-options "boot";
                    };
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = mount-options "root";
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = mount-options "home";
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = mount-options "nix";
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = mount-options "persist";
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = mount-options "log";
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
