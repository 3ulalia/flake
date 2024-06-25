/**
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

{
  inputs,
  outputs,
  lib,
  ...
}:
  let
    inherit (helpers) list-to-attrs-from-key;
    inherit (builtins) attrValues foldl' readDir trace;
    inherit (modules) mapModules;

    helpers = import ./helpers.nix {
      inherit lib inputs;
    };

    modules = import ./modules.nix {
      inherit lib inputs;
    };


    individual-files = readDir ./.;

    /**
      Combines an attrset of libfunctions with a "next" libfile

      combine-files :: {...} -> path -> {...}
     */
    combine-files = starter: next: 
      starter // import next;

    eulib = (mapModules (file: {${file} = (import file {inherit lib inputs outputs;});}) ./.);
    _ignore = trace eulib eulib;

  in 
    (foldl' (a: b: a // b) {} _ignore)
  
