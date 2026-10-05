{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.gtk;
  has = osConfig.host.has;
  t = osConfig.theme;
in
{
  options.features.gtk.enable = lib.mkEnableOption "gtk" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      font = { inherit (t.fonts.sans) name package; };
      iconTheme = { inherit (t.icons) name package; };
      cursorTheme = { inherit (t.cursor) name package size; };
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita-dark";
    };

    home.packages = [ pkgs.glib ];
  };
}
