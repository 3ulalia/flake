{
  config,
  ...
}: {
  programs.ssh = {
    enable = true;
    compression = true;
    includes = [ "config.d/*" ];
  };
}
