# SPDX-License-Identifier: MIT
# (C) 2022 The Asahi Linux Contributors

{
  config,
  pkgs,
  lib,
  ...
}:

let
  t2AppleAudioDSP = pkgs.fetchFromGitHub {
    owner = "lemmyg";
    repo = "t2-apple-audio-dsp";
    rev = "newfirs";
    sha256 = "iPS2wVNdH02NpDsymtMIqWlDMPXLdIBTdbH4uYe9OIE=";
  };
  originalTweeterFilePath = "/usr/share/pipewire/devices/apple/macbook_pro_t2_16_1_tweeters-48k_4.wav";
  newTweeterFilePath = "${t2AppleAudioDSP}/firs/macbook_pro_t2_16_1_tweeters-48k_4.wav";
  originalWooferFilePath = "/usr/share/pipewire/devices/apple/macbook_pro_t2_16_1_woofers-48k_4.wav";
  newWooferFilePath = "${t2AppleAudioDSP}/firs/macbook_pro_t2_16_1_woofers-48k_4.wav";
  configFile = "${t2AppleAudioDSP}/config/10-t2_161_speakers.conf";

  t2ConfigPkg = pkgs.stdenv.mkDerivation {
    name = "t2-speaker-config";
    src = t2AppleAudioDSP;

    buildInputs = [ pkgs.coreutils ]; # For `mkdir`, `sed`, etc.

    buildPhase = ''
      set -eu
      mkdir -p $out/share/pipewire/pipewire.conf.d
      sed -e 's|${originalTweeterFilePath}|${newTweeterFilePath}|g' \
          -e 's|${originalWooferFilePath}|${newWooferFilePath}|g' \
          "${configFile}" > "$out/share/pipewire/pipewire.conf.d/10-t2_161-sink.conf"
    '';

    # Skip installation phase since buildPhase already places files correctly
    installPhase = "true";

    # Add passthru.requiredLv2Packages
    passthru.requiredLv2Packages = [
      # Replace with actual LV2 packages, e.g., pkgs.someLv2Plugin
      # Example: pkgs.lsp-plugins
      pkgs.lsp-plugins
      pkgs.ladspaPlugins
      pkgs.calf
                    pkgs.bankstown-lv2
              pkgs.lv2
              pkgs.swh_lv2
    ];
  };
  en-huh = config.eula.modules.nixos.services.pipewire-sink-conf.enable;

in
{
  options.eula.modules.nixos.services.pipewire-sink-conf.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config.services.pipewire = lib.mkIf en-huh {
    configPackages = [ t2ConfigPkg ];
    extraLv2Packages = with pkgs; [
      lsp-plugins
      ladspaPlugins
      calf
      bankstown-lv2
      lv2
      swh_lv2
    ];
  };

  /*
    config.systemd.user.services.pipewire.environment = lib.mkIf en-huh {
      LASDPA_PATH = "${pkgs.ladspaPlugins}/lib/ladspa";
      LV2_PATH = "${pkgs.lv2}/lib/lv2";
    };
  */

}
