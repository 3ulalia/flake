{
  config,
  ...
} :

let 
  inherit (builtins) attrNames;
in

{


  imports = attrNames (config.eula.lib.modules.nix-modules-in-dir __curPos.file ./.);
}
