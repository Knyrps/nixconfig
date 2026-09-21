{ osConfig, config, lib, pkgs, ... }:

let
  cfg = config.features.cursor;
  has = osConfig.host.has;
in
{
  options.features.cursor.enable = lib.mkEnableOption "cursor theme" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      enable = true;

      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 18;

      x11.enable = true;
      gtk.enable = true;
    };
  };
}
