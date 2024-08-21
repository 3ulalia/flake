{
  bootstrap,
  ...
} : {
  imports = map (n: ./. + ("/" + n)) (bootstrap.modules.nix-modules-in-dir [__curPos.file] ./.);
}
