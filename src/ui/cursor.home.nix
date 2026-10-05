{ osConfig, config, lib, ... }:

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
      inherit (osConfig.theme.cursor) name package size;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}
