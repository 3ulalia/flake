{ pkgs, ... } : {
  
  home.language = {
    base = "es_US.utf8";
    ctype = "es_US.utf8";
    numeric = "es_US.utf8";
    time = "es_US.utf8";
    collate = "es_US.utf8";
    monetary = "es_US.utf8";
    messages = "es_US.utf8";
    paper = "es_US.utf8";
    name = "es_US.utf8";
    address = "es_US.utf8";
    telephone = "es_US.utf8";
    measurement = "es_US.utf8";
  };

  i18n.glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [ "en_US.UTF-8/UTF-8" "es_US.UTF-8/UTF-8" ];
  };
}
