{
  lib,
  ...
}:
let
  inherit (builtins) readDir unsafeDiscardStringContext;
  inherit (lib)
    attrNames
    filterAttrs
    foldl'
    hasSuffix
    removeSuffix
    ;
in
rec {
  shellfile-to-shellname =
    shell-file: unsafeDiscardStringContext (removeSuffix ".nix" (baseNameOf shell-file));

  get-shells =
    path:
    map (n: "${path}/${n}") (
      attrNames (
        filterAttrs (filename: filetype: filetype == "regular" && (hasSuffix ".nix" filename)) (
          readDir path
        )
      )
    );

  generate-shell = pkgs: shell-file: {
    ${shellfile-to-shellname shell-file} = pkgs.mkShell (
      (import shell-file { inherit pkgs; }) // { 
        name = shellfile-to-shellname shell-file; 
        }
    );
  };

  generate-shells =
    path: pkgs: foldl' (a: b: a // b) { } (map (generate-shell pkgs) (get-shells path));

}
