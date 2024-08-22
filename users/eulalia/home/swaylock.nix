{
  config,
  ...
} : {
  config.eula.modules.home-manager.swaylock-effects.spawn-command = [
    "--screenshot" # TODO make more secure
    "--clock"
    "--indicator"
    "--effect-blur"
    "20x10"
  ];
}
