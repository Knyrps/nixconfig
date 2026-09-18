{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 20;

    x11.enable = true;
    gtk.enable = true;
  };
}
