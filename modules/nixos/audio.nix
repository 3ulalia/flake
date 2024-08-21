{
  config,
  options,
  lib,
  ...
} :  
  let 
    inherit (lib) mkDefault mkIf types;
    inherit (config.eula.lib.options) mkOpt;
  in {
   options.eula.modules.nixos.audio = {
    enable = mkOpt types.bool false;
   }; # TODO add more configuration here

   config = mkIf config.eula.modules.nixos.audio.enable {
    services = {
      pipewire = {
        enable = true;
	alsa = {
	  enable = true;
	  support32Bit = true;
	};
 	pulse.enable = true;
	jack.enable = mkDefault false;
        
        wireplumber.extraConfig = {
	"monitor.bluez.properties" = {
	  "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
          };
          "10-disable-camera" = {
            "wireplumber.profiles" = {
              main."monitor.libcamera" = "disabled";
            };
          };
	};
      };
    };
  };
}
