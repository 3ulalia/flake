{
  config,
  eulib,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkIf types;
  inherit (eulib.options) mkOpt;

in
{
  options.eula.modules.nixos.audio = {
    enable = mkOpt types.bool false;
  }; # TODO add more configuration here

  config = mkIf config.eula.modules.nixos.audio.enable ({
    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;

        extraConfig = {
          pipewire-pulse."92-fix-crackle" = {
            "pulse.properties" = {
              "pulse.properties" = {
                "pulse.min.req" = "2048/48000";
                "pulse.default.req" = "2048/48000";
                "pulse.max.req" = "2048/48000";
                "pulse.min.quantum" = "2048/48000";
                "pulse.max.quantum" = "2048/48000";
              };
              "stream.properties" = {
                "node.latency" = "2048/48000";
                "resample.quality" = 1;
              };
            };
          };
          pipewire."92-fix-crackle" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.quantum" = 2048;
              "default.clock.min-quantum" = 2048;
              "default.clock.max-quantum" = 2048;
            };
          };
        };

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
            "bluez5.roles" = [
              "hsp_hs"
              "hsp_ag"
              "hfp_hf"
              "hfp_ag"
            ];
          };
          "10-disable-camera" = {
            "wireplumber.profiles" = {
              main."monitor.libcamera" = "disabled";
            };
          };
        };
      };
    };
    eula.modules.nixos.services.pipewire-sink-conf.enable = false; #config.networking.hostName == "catalina";
  });
}
