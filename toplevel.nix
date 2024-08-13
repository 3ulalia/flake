{
  ...
} :
  let
    a = 1;
  in {
    imports = [
      ./hosts
      ./lib
      ./modules
      ./users
    ];
  }