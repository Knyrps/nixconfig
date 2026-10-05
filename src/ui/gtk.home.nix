{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.gtk;
  has = osConfig.host.has;
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
