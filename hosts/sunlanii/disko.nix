/*
https://haseebmajid.dev/posts/2024-07-30-how-i-setup-btrfs-and-luks-on-nixos-using-disko/
https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
*/
{
  inputs,
  lib,
  ...
} : {

  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk = {
      main = {
	type = "disk";
	device = "/dev/nvme0n1";
	content = {
	  type = "gpt";
	  partitions = {
	    ESP = {
	      label = "efi";
	      name = "ESP";
	      size = "512M";
	      type = "EF00";
	      content = {
	        type = "filesystem";
		format = "vfat";
		mountpoint = "/boot/efi";
		mountOptions = [ "defaults" ];
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
		      mountOptions = [ "subvol=boot" "compress=zstd" "noatime" ];
		    };
		    "/root" = {
		      mountpoint = "/";
		      mountOptions = [ "subvol=root" "compress=zstd" "noatime" ];
		    };
		    "/home" = {
		      mountpoint = "/home";
		      mountOptions = [ "subvol=home" "compress=zstd" "noatime" ];
		    };
		    "/nix"  = {
		      mountpoint = "/nix";
		      mountOptions = [ "subvol=nix"  "compress=zstd" "noatime" ];
		    };
		    "/persist" = {
		      mountpoint = "/persist"; 
		      mountOptions = [ "subvol=persist" "compress=zstd" "noatime" ];
		    };
		    "/log"  = {
		      mountpoint = "/var/log";
		      mountOptions = [ "subvol=log"  "compress=zstd" "noatime" ];
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

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
