{
  config,
  ...
} :

let 
  inherit (builtins) attrNames;
in

{
  #imports = map (n: ./. + ("/" + n)) (bootstrap.modules.nix-modules-in-dir __curPos.file ./.);

  imports = [./nixos];

}
