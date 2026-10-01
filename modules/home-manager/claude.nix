{
  config,
  eulib,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (eulib.options) mkOpt;
  cfg = config.eula.modules.home-manager.claude;
in
{
  options.eula.modules.home-manager.claude = {
    enable = mkOpt types.bool false;
  };
  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      package = pkgs.writeShellScript "claude-wrapper" ''
                echo '
                We trust you have received the usual lecture from the local System
        Administrator. It usually boils down to these three things:

            #1) A computer can never be held accountable.
            #2) A machine will never teach you; you must learn for yourself.
            #3) With great power comes great responsibility.

            Please acknowledge these things by typing "I understand." ' 

            read understand 

            if [[ $understand =~ '[Ii] understand\.' ]]; then
              ${pkgs.claude-code}/bin/claude
            else
              echo "Understand.";
              exit 1
            fi
      '';
    };
    eula.modules.home-manager.impermanence.directories = [ ".claude" ];
  };
}
