{pkgs, ...}: {
  home.packages = [
    # pkgs.omnissa-horizon-client
    pkgs.openconnect
    pkgs.gp-saml-gui
  ];
  home.shellAliases = {
    univpn = "gp-saml-gui -S";
  };
}
