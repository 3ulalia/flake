{ config, lib, ... }:

let
  inherit (lib) foldl' mkIf mkDefault types;
  inherit (config.eula.lib.options) mkOpt;

  cfg = config.eula.modules.services.ephemeral-btrfs;
in {

  options.eula.modules.services.ephemeral-btrfs = {
    enable = mkOpt types.bool false;
    device = mkOpt types.str "cryptid"; # label of partition
  };

  config = mkIf cfg.enable  {
    boot.initrd = {
      enable = mkDefault true;
      systemd.enable = mkDefault true;
      supportedFilesystems = ["btrfs"];

      systemd.services.rollback = {
        description = "Rollback BTRFS root subvolume";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          # after luks unlock
          "systemd-cryptsetup@${cfg.device}.service"
          "initrd-root-device.target"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.type = "oneshot";
        script = let
          #users = foldl' (acc: x: "${acc} {x.name}") "" config.eula.users;
        in ''
          mkdir /btrfs_tmp
          mount /dev/mapper/${cfg.device} /btrfs_tmp

          # create persistent user dirs

          timestamp = $(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+Y-%m-%-d_%H:%M:%S")

          # revert root
          if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          # revert home
          if [[ -e /btrfs_tmp/home ]]; then
            mkdir =p /btrfs_tmp/old_homes
            mv /btrfs_tmp/home "/btrfs_tmp/old_homes/$timestamp"
          fi

          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          # delete old (1 month) saved roots
          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
          done

          # delete old (1 month) saved homes
          for i in $(find /btrfs_tmp/old_homes/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
          done

          # delete old (1 week) saved persist
          for i in $(find /btrfs_tmp/old_persist/ -maxdepth 1 -mtime +7); do
            delete_subvolume_recursively "$i"
          done

          # recreate subvolumes
          btrfs subvolume create /btrfs_tmp/root
          btrfs subvolume create /btrfs_tmp/home

          btrfs subvolume snapshot /btrfs_tmp/persist "/btrfs_tmp/old_persist/$timestamp"

          umount /btrfs_tmp
        '';
      };
    };
  };
}
