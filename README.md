# Eula's Flake!

The purpose of this flake is to define multiple configurations for the various computers that I use in my life, so that any Nix-capable machine that I use can be configured to contain the packages that I need along with my preferred desktop environment.

Currently, there are hosts configured for:

* my personal linux-tomfoolery machine (ThinkPad E14)
* my daily-driver laptop (MacBook Pro 16", 2019)
* my daily-driver laptop, but it's running NixOS because I'm a psycho
* any given server that I want to provision

## Structure

Structurally, this flake is designed to interpret as much information as possible from the directories it manages. Rather than have a "master list" of configurations to manage, adding files to the `hosts/` or `modules/` folders will cause them to be automatically detected and configured on flake rebuild. This is achieved by programmatically determining the objects that need to be evaluated and generated. The downside of this, of course, is that there's not one "master list" to reference; this flake is designed to output a compilation report to `stdout` when it is switched to, allowing the user to understand the results of the rebuild.

### Hosts

To add a host, create a folder in the `hosts/` folder. By convention, this folder will have the hostname of your host, but that's not strictly necessary because this flake determines the hostname from the name in the configuration file itself. The folder _needs to_ contain only a `configuration.nix` file, as well as any dependencies that file might need (e.g. a `hardware_configuration.nix` file for hosts running NixOS).

### Lib

This folder contains various helper functions, divided into the constructs that they operate upon. This allows for a cleaner `flake.nix` file, as well as various levels of abstraction and parametrization. Documentation for these functions is included with the code.

### Modules

Each host defines the modules that it wants to have loaded in its `configuration.nix` file. Module-specific configuration is stored in that module's `configuration.nix`, while user-specific configuration for that module is stored in that user's `home-manager.nix` file. Modules can import other modules; there is one folder (`by-name`) that defines configurations for individual programs, but higher-level modules allow for individual programs to be grouped together (for example, a `rust-dev` module or a `steam` module).

### Users

Although the initial goal for this configuration was to avoid the use of `home-manager` entirely, the reality is that there are many packages (for example, Hyprland) which expose configuration only through user-specific `home-manager` options rather than at the NixOS level. With that in mind, this folder exists to allow for user-level configuration of any individual module. Users are specified in the host's `configuration.nix` file, causing the flake to create and provision those users accordingly.