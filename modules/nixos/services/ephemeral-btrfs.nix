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

    fileSystems = {
      ${config.eula.modules.services.impermanence.root}.neededForBoot = true;
      "/home".neededForBoot = true; # IMPORTANT
    };

    boot.initrd = {
      enable = mkDefault true;
      systemd.enable = mkDefault true;
      supportedFilesystems = ["btrfs"];

      systemd.services.rollback = {
        description = "Rollback BTRFS root subvolume";
        wantedBy = [
          "initrd.target"
        ];
        requires = ["initrd-root-device.target"];
        after = [
          # after luks unlock
          "systemd-cryptsetup@${cfg.device}.service"
          "initrd-root-device.target"
          "systemd-hibernate-resume.service"
        ];
        before = [
          "sysroot.mount"
          "create-needed-for-boot-dirs.service"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir /btrfs_tmp
          mount /dev/mapper/${cfg.device} /btrfs_tmp

          # create persistent user dirs

          last_known_good=$(date -r /btrfs_tmp/persist/var/lib/misc/fs-iter) # get our past timestamp
          stored_iter=$(cat /btrfs_tmp/persist/var/lib/misc/fs-iter)
          if [[ $stored_iter -gt 0 ]]; then # we have revisions of this timestamp
            suffix="_"$stored_iter # set our timestamp
          else # we don't have any revisions of this timestamp
            suffix=""
          fi

          echo $(( $stored_iter + 1 )) > /btrfs_tmp/persist/var/lib/misc/fs-iter # bump iter
          touch -d "$(date -R --date="$last_known_good")" /btrfs_tmp/persist/var/lib/misc/fs-iter # fix modified date
          timestamp=$(date --date="$last_known_good" "+%Y-%m-%d_%H:%M:%S")$suffix

          # revert root
          if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          # revert home
          if [[ -e /btrfs_tmp/home ]]; then
            mkdir -p /btrfs_tmp/old_homes
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

          # recreate subvolumes
          btrfs subvolume create /btrfs_tmp/root
          btrfs subvolume create /btrfs_tmp/home

          mkdir -p /btrfs_tmp/old_persist
          btrfs subvolume snapshot /btrfs_tmp/persist "/btrfs_tmp/old_persist/$timestamp"

          # delete old (1 week) saved persist
          for i in $(find /btrfs_tmp/old_persist/ -maxdepth 1 -mtime +7); do
            delete_subvolume_recursively "$i"
          done

          umount /btrfs_tmp
        '';
      };
    };
  };
}
