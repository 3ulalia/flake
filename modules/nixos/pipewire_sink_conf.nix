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
    rev = "971833705c746b1b02e5a844c4ca7e2d86582dc9";
    sha256 = "iPS2wVNdH02NpDsymtMIqWlDMPXLdIBTdbH4uYe9OIE=";
  };
  originalTweeterFilePath = "/usr/share/pipewire/devices/apple/macbook_pro_t2_16_1_tweeters-48k_4.wav";
  newTweeterFilePath = "${t2AppleAudioDSP}/firs/macbook_pro_t2_16_1_tweeters-48k_4.wav";
  originalWooferFilePath = "/usr/share/pipewire/devices/apple/macbook_pro_t2_16_1_woofers-48k_4.wav";
  newWooferFilePath = "${t2AppleAudioDSP}/firs/macbook_pro_t2_16_1_woofers-48k_4.wav";
  configFile = "${t2AppleAudioDSP}/config/10-t2_161_speakers.conf";

  dspSinkConfig = pkgs.runCommand "10-t2_161_speakers.conf" { } ''
    cat ${configFile} | sed -e 's|${originalTweeterFilePath}|${newTweeterFilePath}|g' \
      -e 's|${originalWooferFilePath}|${newWooferFilePath}|g' > $out
  '';
  en-huh = config.eula.modules.nixos.services.pipewire-sink-conf.enable;

in
{
  options.eula.modules.nixos.services.pipewire-sink-conf.enable = lib.mkOption lib.types.bool false;
  config.services.pipewire.configPackages = lib.mkIf en-huh [
    (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-t2_161-sink.conf" (
      builtins.readFile "${dspSinkConfig}"
    ))
  ];

  config.systemd.user.services.pipewire.environment = lib.mkIf en-huh {
    LASDPA_PATH = "${pkgs.ladspaPlugins}/lib/ladspa";
    LV2_PATH = lib.mkForce "${config.system.path}/lib/lv2";
  };
  config.environment.systemPackages = lib.mkIf en-huh [
    pkgs.ladspaPlugins
    pkgs.calf
    pkgs.lsp-plugins
  ];

}
