/*
*
A note on formatting in the documentation of this code:

Nix does not have strong type signatures for its functions, but this is
  (a) lame
  (b) against the Design Recipe

To preserve my sanity, I've added type signatures in comments above each one
of the functions that I define. These type signatures will look mostly like
OCaml type signatures (blame my Compilers professor), with the modification
that I use ['a] instead of 'a list, because it's shorter and neater.

Attribute sets are represented with curly braces; an attribute set that is
promised to have certain attributes will list them; an attribute set that
has other values will be represented by `...`. For example:

addFoo :: {...} -> {foo: bar; ...}

Because Nix is untyped, lots of "types" are really just attrsets that have
some "magic" keys in them - modules, derivations, etc. Being able to reason
about these "types" would be nice, so if necessary I'll include a
"type signature" that indicates what "types" the data are, as best I can.
*/
{lib, ...}: let
  inherit (builtins) attrNames; # TODO: why;
  inherit (lib) mkOption types;

  eulib = import ./modules.nix {inherit lib;};
in {
  options.eula.lib = mkOption {type = types.attrsOf (types.attrsOf (types.anything));};

  imports = map (n: ./. + ("/" + n)) (attrNames (eulib.config.eula.lib.modules.nix-modules-in-dir [(/. + __curPos.file) ./secrets.nix] ./.));
}
