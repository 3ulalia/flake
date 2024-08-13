{
  eula,
  ...
} :
{
  imports = [(eula.lib.modules.nix-modules-in-dir __curPos.file ./.)];
}