{ pkgs, ... } : {
  home.packages = [
    pkgs.vmware-horizon-client
    pkgs.openconnect
    pkgs.gp-saml-gui
  ];
  home.shellAliases = {
    univpn = "gp-saml-gui -S";
  };
}
