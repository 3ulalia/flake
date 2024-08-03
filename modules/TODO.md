# TODO

To utilize the NixOS module system for configuring a machine, it is 
necessary to create options (lib.mkOption) defining the structure of
each option. This will make it so that when system configurations are 
imported (by being placed in the `imports` section of a module, among
other ways), they are recognized and will be passed to modules that 
require them. 

It's possible to just do this with Nix files, but using modules makes it
(a) easier to define the structure of each option, and
(b) much much much easier to pass configurations around.

Once the options are registered with the module system, they can be used
in places like `hosts/thinkpad/default.nix`, and that information will
then be accessible in places like `users/default.nix`, where it can be 
used to generate the relevant user configurations for the system.