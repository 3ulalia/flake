{
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    ocamlformat
    ocaml
    dune_3
  ] ++ (with pkgs.ocamlPackages; [
    ocaml-lsp
    utop
    odoc
    ocamlformat
    findlib
    extlib
    ocamlbuild
  ]);

}
