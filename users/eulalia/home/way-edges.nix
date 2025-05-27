{ lib, inputs, ... } : {

  imports = [inputs.way-edges.homeManagerModules.default];

  config.programs.way-edges = {
    enable = true;
  };
}
