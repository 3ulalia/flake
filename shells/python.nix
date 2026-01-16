{
  pkgs,
  ...
} :  {

  packages = with pkgs; [
    python3
    ty
    ruff
  ];

}
