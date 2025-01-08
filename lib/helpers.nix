{lib, ...}: let
  inherit (builtins) elemAt findFirst foldl' listToAttrs matchAttrs;

  /*
  *
  Given an input pattern (taken as an attrset) and an attrset, determines if the given pattern
  is contained within the given attrset. Returns the given attrset if it is, and null if it isn't.

  example:

  if_let { platform = "darwin"; arch = "aarch64"; } { platform = "darwin"; }
  => { arch = "aarch64"; platform = "darwin"; }

  if_let { platform = "darwin"; arch = "aarch64"; } { platform = "linux"; }
  => null

  if_let :: {...} -> {...} -> Option<{...}>
  */
  if_let = attrs: pattern:
    if matchAttrs pattern attrs
    then attrs
    else null;
in {
  config.eula.lib.helpers = {
    /*
    *
    Given an input pattern (taken as an attrset) and a list of lists of attribute-result pairs, determines the appropriate result.
    Returns `null` if no result can be found.

    example:

    match { platform = "linux"; arch = "aarch64"; } [
          [ { platform = "darwin"; } "it's macOS" ]
          [ { platform = "linux"; } "it's Linux" ]
        ]
    => "it's Linux"

    kudos to iFreilicht on the NixOS Discourse for writing this!

    match :: {...} -> [[{...} 'a]] -> Option<'a>
    */

    match = v: l:
      elemAt (
        findFirst (
          x: (if_let v (elemAt x 0)) != null
        )
        null
        l
      )
      1;

    /*
    *
    Given a list of attrsets, combines them into one attrset.

    list-to-attrs: [{...}] -> {...}

    */
    list-to-attrs = list: (foldl' (a: b: a // b) {} list);

    /*
    *
    Given a list of attrsets, and a key present in each attrset, create an attrset mapping from
    the value of that key to the attrset itself.

    list-to-attrs-from-key :: string -> [{...}] -> {...}
    */
    list-to-attrs-from-key = field: list:
      listToAttrs (map (v: {
          name = v.${field};
          value = v;
        })
        list);
  };
}
