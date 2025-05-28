{pkgs, ...}: {
  home.packages = [pkgs.prismlauncher];
  eula.modules.home-manager.impermanence.directories = [".local/share/PrismLauncher"];
}
