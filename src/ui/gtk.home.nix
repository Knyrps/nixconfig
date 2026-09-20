{ osConfig, config, lib, ... }:

let
  cfg = config.features.gtk;
  has = osConfig.host.has;
in
{
  options.features.gtk.enable = lib.mkEnableOption "gtk" // {
    default = has "ui";
  };

  config = lib.mkIf cfg.enable {
    gtk.enable = true;
  };
}
