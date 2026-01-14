{config, ...}: {
  programs.ssh = {
    enable = true;
    matchBlocks."*".compression = true;
    includes = ["config.d/*"];
    # extraConfig = "IdentityFile ${config.home.homeDirectory}/.ssh/id_ed25519_THIS_IS_INSECURE_AND_NEEDS_TO_BE_CHANGED";
  };
  # eula.modules.home-manager.impermanence.directories = [ ".ssh" ]; # no longer needed!
}
