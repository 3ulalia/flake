{
  config,
  ...
} :
{
  imports = [(config.eula.lib.modules.nix-modules-in-dir __curPos.file ./.)];
}
